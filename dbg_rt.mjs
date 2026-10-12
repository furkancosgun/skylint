const root = 'C:\\Users\\Teampro\\Desktop\\skylint';
const toFileUrl = (p) => 'file:///' + p.replace(/\\/g, '/');
await import(toFileUrl(root + '/output/init.mjs'));
const abap = globalThis.abap;
const { Lexer } = await import(toFileUrl(root + '/test/lexer.mjs'));
const { buildStatements } = await import(toFileUrl(root + '/test/parser.mjs'));
const { extractSnippet } = await import(toFileUrl(root + '/test/slicer.mjs'));
const { joinSource } = await import(toFileUrl(root + '/test/codeblock.mjs'));
const { enrichStatements } = await import(toFileUrl(root + '/test/abaplint-bridge.mjs'));
const { feedRtti } = await import(toFileUrl(root + '/test/rtti.mjs'));
const { buildProcedureValue, buildProceduresTable, buildObjectValue } = await import(
  toFileUrl(root + '/test/atc-values.mjs')
);
const { createFakes } = await import(toFileUrl(root + '/test/fakes.mjs'));
const { applyFix, findSyntaxErrors } = await import(toFileUrl(root + '/test/roundtrip.mjs'));
import fs from 'node:fs';
import { Registry, MemoryFile } from '@abaplint/core';

const id = process.argv[2];
const method = process.argv[3];
const dir = root + `/tests/fixtures/check_${id}`;
const lines = fs.readFileSync(dir + '/source.abap', 'utf8').split('\n');
if (lines[lines.length - 1] === '') lines.pop();
const { snippet, isDef, offset, object } = extractSnippet(lines, method);
const objectName = object || 'ZSKYLINT_TEST';
const statements = buildStatements(new Lexer(joinSource(snippet)).run());
await feedRtti(joinSource(lines), objectName, abap);
await enrichStatements(statements, joinSource(lines), objectName, offset);

async function allIssues(source) {
  const reg = new Registry();
  reg.addFile(new MemoryFile('zcl_qf_roundtrip.clas.abap', source));
  await reg.parseAsync();
  return reg.findIssues().map((i) => {
    let row = 0;
    try { row = i.getStart().getRow(); } catch { /* ignore */ }
    return `${i.getKey()}@${row}: ${i.getMessage()}`;
  });
}

console.log('=== BASELINE:');
for (const e of await allIssues(joinSource(lines))) console.log('  ', e);

const proc = buildProcedureValue(abap, {
  kind: isDef ? 'DECL' : 'METH', name: 'X', mainKind: 'CLAS', mainName: objectName, statements,
});
const fakes = createFakes(abap, buildProceduresTable(abap, [proc]), objectName);
const mod = await import(toFileUrl(`${root}/output/zcl_skylint_check_${id}.clas.mjs`));
const inst = new mod[`zcl_skylint_check_${id}`]();
await inst.constructor_();
await inst['if_ci_atc_check$set_assistant_factory']({ factory: fakes.factory });
const res = await inst['if_ci_atc_check$run']({
  object: buildObjectValue(abap, objectName), data_provider: fakes.provider,
});
for (const r of res.array()) {
  const g = r.get();
  const pos = g.location.get().position.get();
  let det = [];
  try {
    const d = g.details.get();
    det = (d && d.fixes) || [];
  } catch { /* ignore */ }
  console.log('FINDING', g.code.get().trim(), `${pos.line.get()}:${pos.column.get()}`, `fixes=${det.length}`);
  for (const fix of det) {
    const applied = applyFix(lines, offset, snippet.length, statements, fix);
    if (applied.skipped) { console.log('  skipped'); continue; }
    const startAbs = '...';
    console.log('  newCode:', JSON.stringify(fix.newCode));
    console.log('  patched errors:');
    for (const e of await allIssues(applied.patched.join('\n'))) console.log('   ', e);
  }
}
