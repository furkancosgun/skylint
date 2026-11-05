#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { ArtifactsABAP } from '@abaplint/core';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, '..');

const abapFile = path.join(rootDir, 'src', 'core', '#skyl#cl_cloud_stmts.clas.abap');
const xmlFile = path.join(rootDir, 'src', 'core', '#skyl#cl_cloud_stmts.clas.xml');
const checkOnly = process.argv.includes('--check');

const className = '/SKYL/CL_CLOUD_STMTS';
const appendsPerMethod = 80;

const constructorName = (value) => value?.constructor?.name ?? '';

function unwrapLanguageVersion(matcher) {
  const name = constructorName(matcher);
  if (name === 'LangVersNot' || name === 'LangVers') {
    return unwrapLanguageVersion(matcher.runnable);
  }
  return matcher;
}

function wordSequenceTokens(matcher) {
  if (typeof matcher.stri === 'string' && matcher.stri.length > 0) {
    return matcher.stri.split(/\s+/);
  }
  return (matcher.words ?? [])
    .filter((word) => constructorName(word) === 'Word')
    .map((word) => word.s);
}

// Token lexemes are whitespace separated. Hyphenated keywords such as
// ADD-CORRESPONDING and FIELD-SYMBOLS therefore form a single token.
function extractPrefixes(matcher) {
  const node = unwrapLanguageVersion(matcher);
  if (!node) return [[]];

  const name = constructorName(node);
  if (name === 'Word') return [[node.s]];
  if (name === 'WordSequence') return [wordSequenceTokens(node)];
  if (name === 'Sequence') {
    let result = [[]];
    for (const child of node.list ?? []) {
      const childPrefixes = extractPrefixes(child);
      const combined = [];
      for (const base of result) {
        for (const prefix of childPrefixes) {
          combined.push([...base, ...prefix]);
        }
      }
      result = dedupe(combined);
      if (childPrefixes.some((prefix) => prefix.length === 0)) break;
    }
    return result;
  }
  if (name === 'Alternative' || name === 'AlternativePriority') {
    return dedupe((node.list ?? []).flatMap(extractPrefixes));
  }
  return [[]];
}

function dedupe(prefixes) {
  const seen = new Set();
  const result = [];
  for (const prefix of prefixes) {
    const key = JSON.stringify(prefix);
    if (!seen.has(key)) {
      seen.add(key);
      result.push(prefix);
    }
  }
  return result;
}

function isPrefix(candidate, other) {
  return candidate.length <= other.length && candidate.every((token, index) => token === other[index]);
}

function pruneToShortest(prefixes) {
  return prefixes.filter(
    (candidate) => !prefixes.some((other) => other !== candidate && isPrefix(other, candidate)),
  );
}

function uniqueSorted(patterns) {
  return [...new Set(patterns)].sort((left, right) => left.localeCompare(right));
}

function collectCatalog() {
  const statements = ArtifactsABAP.getStatements();
  const forbidden = [];
  const allowed = [];
  const forbiddenNames = new Set();
  const statementsWithoutPrefixes = [];
  const prefixesByName = new Map();

  for (const statement of statements) {
    const name = constructorName(statement);
    const matcher = statement.getMatcher();
    const isForbidden = constructorName(matcher) === 'LangVersNot' && String(matcher.langVersion) === 'Cloud';
    const prefixes = extractPrefixes(matcher).filter((prefix) => prefix.length > 0);

    if (isForbidden) {
      forbiddenNames.add(name);
      prefixesByName.set(name, prefixes);
      if (prefixes.length === 0) statementsWithoutPrefixes.push(name);
      for (const prefix of pruneToShortest(prefixes)) {
        forbidden.push({ name, prefix });
      }
    } else {
      for (const prefix of prefixes) {
        allowed.push({ name, prefix });
      }
    }
  }

  if (statementsWithoutPrefixes.length > 0) {
    throw new Error(
      `Cannot derive keyword prefixes for Cloud-forbidden statements: ${statementsWithoutPrefixes.join(', ')}`,
    );
  }

  const forbiddenFirstTokens = new Set(forbidden.map((entry) => entry.prefix[0]));
  const allowedRelevant = allowed.filter((entry) => forbiddenFirstTokens.has(entry.prefix[0]));

  const forbiddenPatterns = uniqueSorted(forbidden.map((entry) => entry.prefix.join(' ')));
  const allowedPatterns = uniqueSorted(allowedRelevant.map((entry) => entry.prefix.join(' ')));

  return {
    statements,
    forbiddenNames,
    prefixesByName,
    forbiddenPatterns,
    allowedPatterns,
  };
}

function findPrefix(catalog, statementName, expected) {
  const prefixes = catalog.prefixesByName.get(statementName) ?? [];
  const joined = expected.join(' ');
  return prefixes.some((prefix) => prefix.join(' ') === joined);
}

function validateSpecialCases(catalog) {
  if (!findPrefix(catalog, 'AtPF', ['AT'])) {
    throw new Error('AtPF no longer starts with AT; review the AT PF special case');
  }
  if (!findPrefix(catalog, 'SortDataset', ['SORT'])) {
    throw new Error('SortDataset no longer starts with SORT; review the SORT special case');
  }
  if (!findPrefix(catalog, 'CreateOLE', ['CREATE', 'OBJECT'])) {
    throw new Error('CreateOLE no longer starts with CREATE OBJECT; review the CREATE OBJECT special case');
  }
  if (catalog.forbiddenNames.size === 0) {
    throw new Error('No Cloud-forbidden statements found');
  }
}

function validateTokens(patterns) {
  const invalid = patterns.filter((pattern) => !pattern.split(' ').every((token) => /^[A-Z0-9_/-]+$/.test(token)));
  if (invalid.length > 0) {
    throw new Error(`Unsupported token characters in generated patterns: ${invalid.join(', ')}`);
  }
}

function chunk(items, size) {
  const chunks = [];
  for (let index = 0; index < items.length; index += size) {
    chunks.push(items.slice(index, index + size));
  }
  return chunks;
}

function methodSuffix(index) {
  return String(index + 1).padStart(2, '0');
}

function generateAbap(catalog) {
  const forbiddenChunks = chunk(catalog.forbiddenPatterns, appendsPerMethod);
  const allowedChunks = chunk(catalog.allowedPatterns, appendsPerMethod);
  const lines = [];

  lines.push('" Generated by scripts/generate-cloud-statements.mjs. Do not edit manually.');
  lines.push(`CLASS ${className.toLowerCase()} DEFINITION`);
  lines.push('  PUBLIC');
  lines.push('  CREATE PUBLIC.');
  lines.push('');
  lines.push('  PUBLIC SECTION.');
  lines.push('    TYPES ty_tokens         TYPE STANDARD TABLE OF string WITH EMPTY KEY.');
  lines.push('    TYPES ty_lines          TYPE STANDARD TABLE OF string WITH EMPTY KEY.');
  lines.push('    TYPES ty_token_patterns TYPE STANDARD TABLE OF ty_tokens WITH EMPTY KEY.');
  lines.push('');
  lines.push('    CLASS-METHODS get_forbidden_patterns');
  lines.push('      RETURNING VALUE(rt_patterns) TYPE ty_lines.');
  lines.push('');
  lines.push('    CLASS-METHODS get_allowed_patterns');
  lines.push('      RETURNING VALUE(rt_patterns) TYPE ty_lines.');
  lines.push('');
  lines.push('  PRIVATE SECTION.');
  forbiddenChunks.forEach((_, index) => {
    lines.push(`    CLASS-METHODS add_forbidden_patterns_${methodSuffix(index)}`);
    lines.push('      CHANGING ct_patterns TYPE ty_lines.');
    lines.push('');
  });
  allowedChunks.forEach((_, index) => {
    lines.push(`    CLASS-METHODS add_allowed_patterns_${methodSuffix(index)}`);
    lines.push('      CHANGING ct_patterns TYPE ty_lines.');
    lines.push('');
  });
  lines.push('ENDCLASS.');
  lines.push('');
  lines.push('');
  lines.push(`CLASS ${className.toLowerCase()} IMPLEMENTATION.`);

  lines.push('  METHOD get_forbidden_patterns.');
  forbiddenChunks.forEach((_, index) => {
    lines.push(`    add_forbidden_patterns_${methodSuffix(index)}( CHANGING ct_patterns = rt_patterns ).`);
  });
  lines.push('  ENDMETHOD.');
  lines.push('');

  lines.push('  METHOD get_allowed_patterns.');
  allowedChunks.forEach((_, index) => {
    lines.push(`    add_allowed_patterns_${methodSuffix(index)}( CHANGING ct_patterns = rt_patterns ).`);
  });
  lines.push('  ENDMETHOD.');

  forbiddenChunks.forEach((patterns, index) => {
    lines.push('');
    lines.push(`  METHOD add_forbidden_patterns_${methodSuffix(index)}.`);
    patterns.forEach((pattern) => {
      lines.push(`    APPEND \`${pattern}\` TO ct_patterns.`);
    });
    lines.push('  ENDMETHOD.');
  });

  allowedChunks.forEach((patterns, index) => {
    lines.push('');
    lines.push(`  METHOD add_allowed_patterns_${methodSuffix(index)}.`);
    patterns.forEach((pattern) => {
      lines.push(`    APPEND \`${pattern}\` TO ct_patterns.`);
    });
    lines.push('  ENDMETHOD.');
  });

  lines.push('ENDCLASS.');
  return `${lines.join('\n')}\n`;
}

function generateXml() {
  return `<?xml version="1.0" encoding="utf-8"?>
<abapGit version="v1.0.0" serializer="LCL_OBJECT_CLAS" serializer_version="v1.0.0">
 <asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
  <asx:values>
   <VSEOCLASS>
    <CLSNAME>${className}</CLSNAME>
    <LANGU>E</LANGU>
    <DESCRIPT>skylint: ABAP Cloud Forbidden Statement Catalog</DESCRIPT>
    <STATE>1</STATE>
    <CLSCCINCL>X</CLSCCINCL>
    <FIXPT>X</FIXPT>
    <UNICODE>X</UNICODE>
   </VSEOCLASS>
  </asx:values>
 </asx:abap>
</abapGit>
`;
}

function writeOrCheck(file, content) {
  if (checkOnly) {
    const existing = fs.existsSync(file) ? fs.readFileSync(file, 'utf8') : '';
    if (existing !== content) {
      console.error(`[cloud-statements] Out of date: ${path.relative(rootDir, file)}`);
      console.error('[cloud-statements] Run: node scripts/generate-cloud-statements.mjs');
      process.exitCode = 1;
    }
    return;
  }
  fs.mkdirSync(path.dirname(file), { recursive: true });
  fs.writeFileSync(file, content, 'utf8');
}

const catalog = collectCatalog();
validateSpecialCases(catalog);
validateTokens([...catalog.forbiddenPatterns, ...catalog.allowedPatterns]);

writeOrCheck(abapFile, generateAbap(catalog));
writeOrCheck(xmlFile, generateXml());

if (checkOnly) {
  if (process.exitCode === undefined) {
    console.log(
      `[cloud-statements] Up to date: ${catalog.forbiddenNames.size} Cloud-forbidden statements, ` +
      `${catalog.forbiddenPatterns.length} forbidden and ${catalog.allowedPatterns.length} allowed patterns.`,
    );
  }
} else {
  console.log(
    `[cloud-statements] Generated ${catalog.forbiddenNames.size} Cloud-forbidden statements, ` +
    `${catalog.forbiddenPatterns.length} forbidden and ${catalog.allowedPatterns.length} allowed patterns.`,
  );
}
