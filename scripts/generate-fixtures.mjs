import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, '..');
const checksDir = path.join(rootDir, 'src', 'checks');
const testsDir = path.join(rootDir, 'src', 'tests');

if (!fs.existsSync(testsDir)) {
  fs.mkdirSync(testsDir, { recursive: true });
}

function extractStringLines(block) {
  const lines = [];
  const regex = /`([^`]*)`/g;
  let m;
  while ((m = regex.exec(block)) !== null) {
    lines.push(m[1]);
  }
  return lines;
}

function extractMethodBody(content, methodName) {
  const regex = new RegExp(`METHOD\\s+${methodName}\\.([\\s\\S]*?)ENDMETHOD\\.`, 'i');
  const match = content.match(regex);
  if (!match) return [];
  return extractStringLines(match[1]);
}

const checkFiles = fs.readdirSync(checksDir)
  .filter(f => f.endsWith('.clas.testclasses.abap'))
  .sort();

console.log(`Generating test fixtures for ${checkFiles.length} check classes in ${testsDir}...`);

for (const f of checkFiles) {
  const match = f.match(/check_(\d+)/i);
  if (!match) continue;
  const num = match[1];
  const className = `ZCL_SKYLINT_TEST_${num}`;
  const content = fs.readFileSync(path.join(checksDir, f), 'utf8');

  const findingLines = extractMethodBody(content, 'test_finding');
  const cleanLines = extractMethodBody(content, 'test_clean');

  // Check if finding lines are top-level class definitions (e.g. checks 027, 048, 055, 057, 058)
  const isClassDef = findingLines.some(l => /^\s*CLASS\s+\w+\s+DEFINITION/i.test(l));

  let abapCode = '';
  if (isClassDef) {
    // Put class definitions as local classes, followed by test harness
    const topDefs = [...findingLines, ...cleanLines].filter(l => l.trim().length > 0);
    abapCode = `CLASS ${className.toLowerCase()} DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS ${className.toLowerCase()} IMPLEMENTATION.
  METHOD with_finding.
${findingLines.map(l => '    " ' + l).join('\n')}
  ENDMETHOD.

  METHOD clean_code.
${cleanLines.map(l => '    " ' + l).join('\n')}
  ENDMETHOD.
ENDCLASS.
`;
  } else {
    const findingBody = findingLines.length > 0
      ? findingLines.map(l => '    ' + l).join('\n')
      : '    RETURN.';
    const cleanBody = cleanLines.length > 0
      ? cleanLines.map(l => '    ' + l).join('\n')
      : '    RETURN.';

    abapCode = `CLASS ${className.toLowerCase()} DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS ${className.toLowerCase()} IMPLEMENTATION.
  METHOD with_finding.
${findingBody}
  ENDMETHOD.

  METHOD clean_code.
${cleanBody}
  ENDMETHOD.
ENDCLASS.
`;
  }

  const xmlCode = `<?xml version="1.0" encoding="utf-8"?>
<abapGit version="v1.0.0" serializer="LCL_OBJECT_CLAS" serializer_version="v1.0.0">
 <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
   <VSEOCLASS>
    <CLSNAME>${className}</CLSNAME>
    <LANGU>E</LANGU>
    <DESCRIPT>skylint: Fixture for Check ${num}</DESCRIPT>
    <STATE>1</STATE>
    <CLSCCINCL>X</CLSCCINCL>
    <FIXPT>X</FIXPT>
    <UNICODE>X</UNICODE>
   </VSEOCLASS>
  </asx:values>
 </asx:abap>
</abapGit>
`;

  fs.writeFileSync(path.join(testsDir, `${className.toLowerCase()}.clas.abap`), abapCode, 'utf8');
  fs.writeFileSync(path.join(testsDir, `${className.toLowerCase()}.clas.xml`), xmlCode, 'utf8');
}

console.log(`✓ Successfully generated ${checkFiles.length} fixtures in src/tests/!`);
