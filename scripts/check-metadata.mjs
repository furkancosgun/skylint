import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, '..');
const checksDir = path.join(rootDir, 'src', 'checks');

export function getChecksDir() {
  return checksDir;
}

export function readCheckSource(rule) {
  const filePath = path.join(checksDir, `${rule.className.toLowerCase()}.clas.abap`);
  if (!fs.existsSync(filePath)) return null;
  return fs.readFileSync(filePath, 'utf8');
}

export function getCheckDescription(rule) {
  const content = readCheckSource(rule);
  if (content) {
    const match = content.match(/description\s*=\s*'([^']+)'/);
    if (match) {
      let desc = match[1].replace(/^skylint:\s*/i, '').trim();
      if (desc.length > 60) {
        throw new Error(`ABAP class ${rule.className} description exceeds 60 characters (${desc.length}): "${desc}"`);
      }
      return desc;
    }
  }
  return `Check rule ${rule.ruleId}`.slice(0, 60);
}

export function getFindingCode(rule) {
  const content = readCheckSource(rule);
  if (!content) return 'UNKNOWN';
  const codeValMatch = content.match(/c_finding_codes[\s\S]*?VALUE\s*'([A-Za-z0-9_]+)'/);
  let findingCode = codeValMatch ? codeValMatch[1].trim() : '';
  if (!findingCode) {
    const codeMatch = content.match(/code\s*=\s*c_finding_codes-([a-zA-Z0-9_]+)/);
    findingCode = codeMatch ? codeMatch[1].toUpperCase() : 'UNKNOWN';
  }
  return findingCode;
}

export function getPseudoComment(rule) {
  const content = readCheckSource(rule);
  if (content) {
    const pcomMatch = content.match(/c_pseudo_comment\s+TYPE\s+string\s+VALUE\s+'([^']+)'/);
    if (pcomMatch) return `"#EC ${pcomMatch[1].trim()}"`;
  }
  return `"#EC ${rule.pseudoComment}"`;
}

export function stripAbapQuotes(value) {
  if (typeof value !== 'string') return value;
  const trimmed = value.trim();
  const match = trimmed.match(/^'((?:[^']|'')*)'$/);
  if (!match) return trimmed;
  return match[1].replace(/''/g, "'");
}

function readAttributeRaw(content, varName) {
  const re = new RegExp(
    `DATA\\s+${varName}\\s+TYPE\\s+[^\\n]*?VALUE\\s+('(?:[^']|'')*'|abap_true|abap_false|-?\\d+|[^\\s.]+)`,
    'i'
  );
  const match = content.match(re);
  return match ? match[1].trim() : '';
}

export function getCheckParameters(rule) {
  const content = readCheckSource(rule);
  if (!content) return undefined;

  const attrMatch = content.match(/attributes\s*=\s*VALUE\s*#\([\s\S]*?\)\s*\)\s*\)/);
  if (!attrMatch) return undefined;

  const bound = [...attrMatch[0].matchAll(/name\s*=\s*['"]([^'"\s]+)['"][\s\S]*?REF\s*#\(\s*([a-zA-Z0-9_]+)\s*\)/g)];
  if (bound.length === 0) return undefined;

  return bound.map(([_, name, varName]) => {
    const raw = readAttributeRaw(content, varName);
    const lower = raw.toLowerCase();
    let value = '';
    if (lower === 'abap_true') {
      value = 'true';
    } else if (lower === 'abap_false') {
      value = 'false';
    } else if (raw.startsWith("'")) {
      value = stripAbapQuotes(raw);
    } else {
      value = raw;
    }
    return { name, value };
  });
}

export function isRemoteEnabled(rule) {
  const content = readCheckSource(rule);
  if (!content) return true;
  if (/remote_enablement\s*=\s*abap_false/i.test(content)) {
    return false;
  }
  return true;
}

export function detectQuickFixStatus(content) {
  if (!content) return '✗';
  const hasQuickFixCall = /quickfix_codes|quickfix_replace|quickfix_insert_before|quickfix_insert_after|quickfix_delete|c_quickfix_codes|io_details/i.test(content);
  const hasQuickFixComment = /quickfix\s*:\s*(ready|true|enabled|yes)/i.test(content);
  return (hasQuickFixCall || hasQuickFixComment) ? '⚡ Ready' : '✗';
}

export function extractAttributes(content) {
  const attrBlockMatch = content.match(/attributes\s*=\s*VALUE\s*#\(([\s\S]*?)\)\s*\)\s*\./);
  if (!attrBlockMatch) return [];
  const block = attrBlockMatch[1];
  const defaultKindMatch = block.match(/kind\s*=\s*if_ci_atc_check_meta_data=>attribute_kinds-([a-z]+)/);
  const defaultKind = defaultKindMatch ? defaultKindMatch[1] : 'elementary';

  const results = [];
  const entries = [...block.matchAll(/\(\s*name\s*=\s*'([A-Za-z0-9_]+)'[\s\S]*?value\s*=\s*REF\s*#\(\s*([a-zA-Z0-9_]+)\s*\)/g)];
  for (const e of entries) {
    const name = e[1];
    const varName = e[2];
    const kindMatch = e[0].match(/kind\s*=\s*if_ci_atc_check_meta_data=>attribute_kinds-([a-z]+)/);
    const kind = kindMatch ? kindMatch[1] : defaultKind;
    const raw = readAttributeRaw(content, varName);
    const rawLower = raw.toLowerCase();
    let defVal = '';
    if (rawLower === 'abap_true') {
      defVal = 'true';
    } else if (rawLower === 'abap_false') {
      defVal = 'false';
    } else {
      defVal = stripAbapQuotes(raw);
    }

    let resolvedKind = 'String';
    if (kind === 'boolean') {
      resolvedKind = 'Boolean';
    } else if (/^\d+$/.test(defVal)) {
      resolvedKind = 'Integer';
    }

    results.push({
      name,
      kind: resolvedKind,
      defaultValue: defVal,
    });
  }
  return results;
}
