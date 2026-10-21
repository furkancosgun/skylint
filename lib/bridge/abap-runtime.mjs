import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { resolveRule } from '../../scripts/rules-data.mjs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, '..', '..');
const outDir = path.join(rootDir, 'output');
const projectDir = fs.existsSync(path.join(outDir, 'project')) ? path.join(outDir, 'project') : outDir;
const toFileUrl = (p) => pathToFileURL(p).href;

export async function initRuntime() {
  await import(toFileUrl(path.join(outDir, 'init.mjs')));
  return globalThis.abap;
}

export function createLoader(abap) {
  const cache = new Map();
  return async function getCheck(target) {
    const rule = typeof target === 'object' && target !== null ? target : resolveRule(target);
    if (!rule) {
      throw new Error(`Rule not found for: ${JSON.stringify(target)}`);
    }
    const key = rule.ruleId;

    if (!cache.has(key)) {
      const clsName = rule.className.toLowerCase();
      const checkPath = path.join(projectDir, `${clsName}.clas.mjs`);
      if (!fs.existsSync(checkPath)) {
        throw new Error(`Compiled check not found: ${checkPath}`);
      }
      const mod = await import(toFileUrl(checkPath));
      const CheckClass = mod[clsName];
      if (!CheckClass) {
        throw new Error(`Class ${clsName} not exported from ${checkPath}`);
      }
      const inst = new CheckClass();
      await inst.constructor_();
      cache.set(key, { inst, rule });
    }
    return cache.get(key);
  };
}
