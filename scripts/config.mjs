import fs from 'node:fs';
import path from 'node:path';
import { parse as parseYaml } from 'yaml';

import { resolveRule } from './rules-data.mjs';

const SEVERITIES = ['error', 'warning', 'note'];
export const SEV_RANK = { error: 0, warning: 1, note: 2 };

const CANDIDATE_NAMES = ['skylint.yaml', '.skylint.yaml', 'skylint.yml'];

export function defaultConfigText() {
  return `# skylint configuration. Auto-discovered as skylint.yaml, .skylint.yaml
# or skylint.yml in the scanned folder or the working directory.
# Hide findings below this severity: error | warning | note
minSeverity: warning
# Skip files (glob patterns, relative to the scanned folder)
exclude:
  - "**/*.testclasses.abap"
# Per-check overrides by rule id
checks:
  # prefer-lines: { enabled: false }
  # no-empty-block: { severity: note }
  # max-method-length: { enabled: false }
`;
}

export function findConfigFile(folder, explicit) {
  if (explicit) {
    const resolved = path.resolve(explicit);
    if (!fs.existsSync(resolved)) throw new Error(`Config not found: ${explicit}`);
    return resolved;
  }
  for (const name of CANDIDATE_NAMES) {
    const inFolder = path.join(folder, name);
    if (fs.existsSync(inFolder)) return inFolder;
  }
  for (const name of CANDIDATE_NAMES) {
    const inCwd = path.resolve(name);
    if (fs.existsSync(inCwd)) return inCwd;
  }
  return null;
}

function warn(msg) {
  console.error(`skylint.yaml: ${msg}`);
}

function normId(raw) {
  const rule = resolveRule(raw);
  return rule ? rule.ruleId : null;
}

export function loadConfig(file) {
  const cfg = { file, minSeverity: null, exclude: [], checks: new Map() };
  if (!file) return cfg;
  let doc;
  try {
    doc = parseYaml(fs.readFileSync(file, 'utf8'));
  } catch (e) {
    throw new Error(`Cannot parse ${file}: ${e.message}`);
  }
  if (!doc || typeof doc !== 'object' || Array.isArray(doc)) {
    warn('top level must be a mapping, ignoring file');
    return cfg;
  }
  for (const key of Object.keys(doc)) {
    if (!['minSeverity', 'exclude', 'checks'].includes(key)) warn(`unknown key '${key}', ignored`);
  }
  if (doc.minSeverity !== undefined) {
    if (!SEVERITIES.includes(doc.minSeverity)) warn(`invalid minSeverity '${doc.minSeverity}', ignored`);
    else cfg.minSeverity = doc.minSeverity;
  }
  if (doc.exclude !== undefined) {
    if (!Array.isArray(doc.exclude)) warn('exclude must be a list, ignored');
    else cfg.exclude = doc.exclude.filter((p) => typeof p === 'string');
  }
  if (doc.checks !== undefined) {
    if (!doc.checks || typeof doc.checks !== 'object' || Array.isArray(doc.checks)) {
      warn('checks must be a mapping, ignored');
    } else {
      for (const [rawId, entry] of Object.entries(doc.checks)) {
        const id = normId(rawId);
        if (!id) {
          warn(`invalid check id '${rawId}', ignored`);
          continue;
        }
        const conf = { enabled: true, severity: null };
        if (entry !== undefined && entry !== null) {
          if (typeof entry !== 'object') {
            warn(`checks.${rawId} must be a mapping, ignored`);
            continue;
          }
          if (entry.enabled !== undefined) conf.enabled = entry.enabled !== false;
          if (entry.severity !== undefined) {
            if (!SEVERITIES.includes(entry.severity)) warn(`invalid severity for ${id}, ignored`);
            else conf.severity = entry.severity;
          }
        }
        cfg.checks.set(id, conf);
      }
    }
  }
  return cfg;
}

export function isEnabled(cfg, target) {
  const rule = resolveRule(target);
  const key = rule ? rule.ruleId : target;
  const conf = cfg.checks.get(key);
  return !conf || conf.enabled;
}

export function severityOverride(cfg, target) {
  const rule = resolveRule(target);
  const key = rule ? rule.ruleId : target;
  const conf = cfg.checks.get(key);
  return (conf && conf.severity) || null;
}

function escapeRegExp(s) {
  return s.replace(/[.+^${}()|[\]\\]/g, '\\$&');
}

export function globToRegExp(glob) {
  let re = '';
  let i = 0;
  while (i < glob.length) {
    const c = glob[i];
    if (c === '*') {
      if (glob[i + 1] === '*') {
        if (glob[i + 2] === '/') {
          re += '(?:.*/)?';
          i += 3;
        } else {
          re += '.*';
          i += 2;
        }
      } else {
        re += '[^/]*';
        i += 1;
      }
    } else if (c === '?') {
      re += '[^/]';
      i += 1;
    } else {
      re += escapeRegExp(c);
      i += 1;
    }
  }
  return new RegExp(`^${re}$`);
}

export function matchesExclude(relPosix, patterns) {
  const base = relPosix.split('/').pop();
  for (const pat of patterns) {
    const re = globToRegExp(pat);
    if (re.test(relPosix)) return true;
    if (!pat.includes('/') && re.test(base)) return true;
  }
  return false;
}
