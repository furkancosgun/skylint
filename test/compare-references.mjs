#!/usr/bin/env node
// Compares the findings of the heuristic compiler-reference resolver with the
// abaplint backed one. Used to validate the migration of the test process.
//
//   node test/compare-references.mjs [ruleId ...]
import { loadFixture, runRow, discoverChecks } from './run.mjs';
import { initRuntime, createLoader } from '../lib/bridge/abap-runtime.mjs';
import { RULES, resolveRule } from '../scripts/rules-data.mjs';

function key(f) {
  return `${f.code}@${f.line}:${f.column}`;
}

function diff(a, b) {
  const ka = a.map(key).sort();
  const kb = b.map(key).sort();
  const onlyA = ka.filter((x) => !kb.includes(x));
  const onlyB = kb.filter((x) => !ka.includes(x));
  return { onlyA, onlyB, same: onlyA.length === 0 && onlyB.length === 0 };
}

async function main() {
  const argv = process.argv.slice(2);
  const flagValue = (flag, fallback) => {
    const idx = argv.indexOf(flag);
    return idx >= 0 && argv[idx + 1] ? argv[idx + 1].toLowerCase() : fallback;
  };
  const modeA = flagValue('--mode-a', (process.env.SKYLINT_REFS_A || 'heuristic').toLowerCase());
  const modeB = flagValue('--mode-b', (process.env.SKYLINT_REFS_B || 'hybrid').toLowerCase());
  const args = argv.filter((a, i) => !a.startsWith('--') && !(i > 0 && argv[i - 1].startsWith('--')));
  let rules = RULES;
  if (args.length > 0) {
    rules = args.map((a) => resolveRule(a)).filter(Boolean);
  }

  const abap = await initRuntime();
  const getCheck = createLoader(abap);

  let compared = 0;
  let same = 0;
  const differences = [];

  for (const rule of rules) {
    const { lines, expected } = loadFixture(rule);
    for (const row of expected) {
      let first;
      let second;
      try {
        process.env.SKYLINT_REFERENCES = modeA;
        first = await runRow({ abap, getCheck, rule, fullLines: lines, row });
        process.env.SKYLINT_REFERENCES = modeB;
        second = await runRow({ abap, getCheck, rule, fullLines: lines, row });
      } catch (err) {
        differences.push({ rule: rule.ruleId, method: row.method, error: err.message });
        continue;
      }
      compared += 1;
      const d = diff(first.findings || [], second.findings || []);
      if (d.same) {
        same += 1;
      } else {
        differences.push({
          rule: rule.ruleId,
          method: row.method,
          onlyHeuristic: d.onlyA,
          onlyAbaplint: d.onlyB,
        });
      }
    }
  }

  console.log(`\ncompared ${compared} rows (${modeA} vs ${modeB}), identical ${same}, different ${differences.length}`);
  for (const d of differences) {
    console.log(`\n${d.rule}/${d.method}`);
    if (d.error) {
      console.log(`  error: ${d.error}`);
      continue;
    }
    if (d.onlyHeuristic.length) console.log(`  only ${modeA}: ${d.onlyHeuristic.join(', ')}`);
    if (d.onlyAbaplint.length) console.log(`  only ${modeB}: ${d.onlyAbaplint.join(', ')}`);
  }
  process.exit(0);
}

main();
