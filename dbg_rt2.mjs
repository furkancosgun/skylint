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
const { applyFix, validateFix } = await import(toFileUrl(root + '/test/roundtrip.mjs'));
import fs from 'node:fs';

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
const fullSource = joinSource(lines);
for (const r of res.array()) {
  const g = r.get();
  let det = { codes: [], fixes: [] };
  try {
    const d = g.details.get();
    if (d) det = { codes: d.codes || [], fixes: d.fixes || [] };
  } catch { /* ignore */ }
  console.log('FINDING', g.code.get().trim(), 'fixes:', det.fixes.length);
  for (const fix of det.fixes) {
    console.log('  ctx:', JSON.stringify(fix.context), 'newCode:', JSON.stringify(fix.newCode));
    const applied = (await import(toFileUrl(root + '/test/roundtrip.mjs'))).applyFix(
      lines, offset, snippet.length, statements, fix);
    if (!applied.skipped) {
      const s = applied.patched.join('\n').split('\n');
      // print patched region
      console.log('  patched region:');
      const sf = fix.context.statements.from;
      const base = offset + statements[sf - 1].position.line - 1;
      for (let i = Math.max(0, base - 2); i < Math.min(s.length, base + 4); i++) console.log(`   ${i + 1}: ${s[i]}`);
    }
    console.log('  errors:', await validateFix(fullSource, lines, offset, snippet.length, statements, fix));
  }
}
