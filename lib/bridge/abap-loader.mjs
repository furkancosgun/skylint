import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';

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

  const clsName = className.toLowerCase();
  const checkPath = path.join(projectDir, `${clsName}.clas.mjs`);
  if (!fs.existsSync(checkPath)) {
    throw new Error(`Compiled check not found: ${checkPath}`);
  }

  const mod = await import(toFileUrl(checkPath));
  const CheckClass = mod[clsName] || mod[upper];
  if (!CheckClass) {
    throw new Error(`Class ${clsName} not exported from check module`);
  }

  const inst = new CheckClass();
  await inst.constructor_();
  checkInstancesCache.set(upper, inst);
  return inst;
}

export function clearCheckCache() {
  checkInstancesCache.clear();
}
