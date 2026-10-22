import fs from 'node:fs';
import path from 'node:path';

const distDir = path.resolve('docs/.vitepress/dist');

if (!fs.existsSync(distDir)) {
  console.error(`Missing ${distDir}. Run "npm run docs:build" first.`);
  process.exit(1);
}

function collectHtmlFiles(dir) {
  const files = [];

  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      files.push(...collectHtmlFiles(fullPath));
    } else if (entry.isFile() && entry.name.endsWith('.html')) {
      files.push(fullPath);
    }
  }

  return files;
}

function isExternal(href) {
  return /^(?:[a-z][a-z\d+.-]*:|\/\/|#)/i.test(href);
}

function existsInDist(pathname) {
  const normalized = pathname.replace(/\\/g, '/');
  const candidates = [];
  const withoutLeadingSlash = normalized.replace(/^\/+/, '');

  if (normalized.endsWith('/')) {
    candidates.push(path.join(distDir, withoutLeadingSlash, 'index.html'));
    candidates.push(path.join(distDir, `${withoutLeadingSlash.replace(/\/+$/, '')}.html`));
  } else if (path.posix.extname(normalized)) {
    candidates.push(path.join(distDir, withoutLeadingSlash));
  } else {
    candidates.push(path.join(distDir, `${withoutLeadingSlash}.html`));
    candidates.push(path.join(distDir, withoutLeadingSlash, 'index.html'));
  }

  return candidates.some((candidate) => {
    const resolved = path.resolve(candidate);
    return (resolved === distDir || resolved.startsWith(`${distDir}${path.sep}`)) && fs.existsSync(resolved);
  });
}

const htmlFiles = collectHtmlFiles(distDir);
const errors = [];
const checked = new Set();

for (const file of htmlFiles) {
  const html = fs.readFileSync(file, 'utf8');
  const relativePath = `/${path.relative(distDir, file).replace(/\\/g, '/')}`;
  const pageUrl = `https://docs.local${relativePath}`;

  for (const match of html.matchAll(/\b(?:href|src)="([^"]+)"/g)) {
    const href = match[1].replace(/&amp;/g, '&').trim();

    if (!href || isExternal(href)) continue;

    let url;
    try {
      url = new URL(href, pageUrl);
    } catch {
      errors.push(`${relativePath}: invalid URL "${href}"`);
      continue;
    }

    if (url.host !== 'docs.local') continue;

    const pathname = decodeURIComponent(url.pathname);
    const key = `${relativePath} -> ${pathname}`;
    if (checked.has(key)) continue;
    checked.add(key);

    if (!existsInDist(pathname)) {
      errors.push(`${relativePath}: broken internal link "${href}"`);
    }
  }
}

if (errors.length > 0) {
  console.error(`Found ${errors.length} broken internal link(s):`);
  for (const error of errors.slice(0, 100)) {
    console.error(`- ${error}`);
  }
  if (errors.length > 100) {
    console.error(`...and ${errors.length - 100} more.`);
  }
  process.exit(1);
}

console.log(`Link check passed: ${htmlFiles.length} HTML pages, ${checked.size} unique internal links.`);
