import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { RULE_MODULES } from '../rules-registry.mjs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, '..', '..');
const outDir = path.join(rootDir, 'output');
const projectDir = fs.existsSync(path.join(outDir, 'project')) ? path.join(outDir, 'project') : outDir;
const toFileUrl = (p) => pathToFileURL(p).href;

const checkInstancesCache = new Map();

export async function getCheckInstance(abap, className) {
  const upper = className.toUpperCase();
  if (checkInstancesCache.has(upper)) {
    return checkInstancesCache.get(upper);
  }

  const entry = RULE_MODULES[upper];
  if (!entry) {
    throw new Error(`Class not registered in rules-registry: ${className}`);
  }
  // pathToFileURL percent-encodes the '#' in the filesystem path itself.
  const checkPath = path.join(projectDir, entry.file);
  if (!fs.existsSync(checkPath)) {
    throw new Error(`Compiled rule not found: ${checkPath}`);
  }

  const mod = await import(toFileUrl(checkPath));
  const CheckClass = mod[entry.sym];
  if (!CheckClass) {
    throw new Error(`Class symbol ${entry.sym} not exported from ${checkPath}`);
  }

  const inst = new CheckClass();
  await inst.constructor_();
  checkInstancesCache.set(upper, inst);
  return inst;
}

export function clearCheckCache() {
  checkInstancesCache.clear();
}

export const getRuleInstance = getCheckInstance;
export const clearRuleCache = clearCheckCache;

