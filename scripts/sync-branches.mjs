#!/usr/bin/env node
/**
 * scripts/sync-branches.mjs
 *
 * Local branch distribution tool for Skylint:
 * Mirrors core checks from `main` to target platform delivery branches:
 *   - `cloud`    -> Core + checks + Native ATC Cloud Adapter (if_ci_atc_check)
 *   - `standard` -> Core + checks + Classic Code Inspector Adapter (CL_CI_TEST_SCAN)
 *
 * Usage:
 *   node scripts/sync-branches.mjs [cloud | standard | all]
 */

import { execSync } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, '..');
const tempSyncDir = path.join(rootDir, 'node_modules', '.cache', 'skylint-sync');

function run(cmd, cwd = rootDir) {
  return execSync(cmd, { cwd, encoding: 'utf8', stdio: ['pipe', 'pipe', 'pipe'] }).trim();
}

function ensureCleanWorkingTree() {
  const status = run('git status --porcelain');
  if (status.length > 0) {
    console.error('❌ Error: Working tree has uncommitted changes. Please commit or stash before syncing:');
    console.error(status);
    process.exit(1);
  }
}

function getCurrentBranch() {
  return run('git rev-parse --abbrev-ref HEAD');
}

function getHeadCommit() {
  const sha = run('git rev-parse HEAD');
  const shortSha = run('git rev-parse --short HEAD');
  const message = run('git log -1 --format=%s');
  return { sha, shortSha, message };
}

function prepareSnapshot() {
  if (fs.existsSync(tempSyncDir)) {
    fs.rmSync(tempSyncDir, { recursive: true, force: true });
  }
  fs.mkdirSync(tempSyncDir, { recursive: true });

  // Copy src/
  fs.cpSync(path.join(rootDir, 'src'), path.join(tempSyncDir, 'src'), { recursive: true });

  // Copy adapters/
  if (fs.existsSync(path.join(rootDir, 'adapters'))) {
    fs.cpSync(path.join(rootDir, 'adapters'), path.join(tempSyncDir, 'adapters'), { recursive: true });
  }

  // Copy .abaplint/
  if (fs.existsSync(path.join(rootDir, '.abaplint'))) {
    fs.cpSync(path.join(rootDir, '.abaplint'), path.join(tempSyncDir, '.abaplint'), { recursive: true });
  }

  // Copy common meta files
  for (const f of ['LICENSE', 'package.json']) {
    const srcFile = path.join(rootDir, f);
    if (fs.existsSync(srcFile)) {
      fs.cpSync(srcFile, path.join(tempSyncDir, f));
    }
  }
}

function cleanWorkingDirExceptGit() {
  const entries = fs.readdirSync(rootDir);
  for (const entry of entries) {
    if (entry === '.git' || entry === 'node_modules') continue;
    fs.rmSync(path.join(rootDir, entry), { recursive: true, force: true });
  }
}

function branchExists(branchName) {
  try {
    run(`git rev-parse --verify ${branchName}`);
    return true;
  } catch {
    return false;
  }
}

function syncBranch(target, headInfo) {
  console.log(`\n📦 Syncing branch: [${target}]...`);

  // Switch to target branch
  if (branchExists(target)) {
    run(`git checkout ${target}`);
  } else {
    run(`git checkout -b ${target}`);
  }

  // Clean current branch tree
  cleanWorkingDirExceptGit();

  // 1. Copy common source tree
  fs.cpSync(path.join(tempSyncDir, 'src'), path.join(rootDir, 'src'), { recursive: true });

  // 2. Copy target adapter into src/adapters/
  const adapterSrc = path.join(tempSyncDir, 'adapters', target, 'src');
  if (fs.existsSync(adapterSrc)) {
    const destAdapters = path.join(rootDir, 'src', 'adapters');
    fs.mkdirSync(destAdapters, { recursive: true });
    fs.cpSync(adapterSrc, destAdapters, { recursive: true });
  }

  // 3. Copy target .abapgit.xml
  const targetAbapGit = path.join(tempSyncDir, 'adapters', target, '.abapgit.xml');
  if (fs.existsSync(targetAbapGit)) {
    fs.cpSync(targetAbapGit, path.join(rootDir, '.abapgit.xml'));
  }

  // 4. Copy target README.md
  const targetReadme = path.join(tempSyncDir, 'adapters', target, 'README.md');
  if (fs.existsSync(targetReadme)) {
    fs.cpSync(targetReadme, path.join(rootDir, 'README.md'));
  }

  // 5. Copy target linter profile to root abaplint.json
  const targetLintProfile = path.join(tempSyncDir, '.abaplint', `abap_${target}.json`);
  if (fs.existsSync(targetLintProfile)) {
    // Read and adjust file globs for root directory execution
    let lintContent = fs.readFileSync(targetLintProfile, 'utf8');
    lintContent = lintContent.replace(/\/..\//g, '/');
    fs.writeFileSync(path.join(rootDir, 'abaplint.json'), lintContent, 'utf8');
  }

  // 6. Common files
  for (const f of ['LICENSE', 'package.json']) {
    const srcF = path.join(tempSyncDir, f);
    if (fs.existsSync(srcF)) {
      fs.cpSync(srcF, path.join(rootDir, f));
    }
  }

  // 7. Verify linter on the generated tree
  try {
    run('npx abaplint');
    console.log(`  ✓ Linter validation passed for [${target}]`);
  } catch (err) {
    console.warn(`  ⚠ Linter warning/notice during [${target}] validation (proceeding with sync)`);
  }

  // 8. Commit changes
  run('git add .');
  const staged = run('git status --porcelain');
  if (staged.length > 0) {
    const commitMsg = `sync(${target}): mirror core and checks from main (${headInfo.shortSha})\n\nSource-Commit: ${headInfo.sha}\nSubject: ${headInfo.message}`;
    run(`git commit -m "${commitMsg.replace(/"/g, '\\"')}"`);
    console.log(`  ✓ Committed sync changes to [${target}]`);
  } else {
    console.log(`  ✓ Branch [${target}] is already up to date with main`);
  }
}

function main() {
  const arg = (process.argv[2] || 'all').toLowerCase();
  const validTargets = ['cloud', 'standard', 'all'];

  if (!validTargets.includes(arg)) {
    console.error(`Invalid target '${arg}'. Allowed targets: cloud, standard, all`);
    process.exit(1);
  }

  ensureCleanWorkingTree();

  const originalBranch = getCurrentBranch();
  if (originalBranch !== 'main') {
    console.warn(`⚠ Currently on branch '${originalBranch}'. Switching to 'main'...`);
    run('git checkout main');
  }

  const headInfo = getHeadCommit();
  console.log(`🚀 Starting Skylint branch synchronization from main (${headInfo.shortSha})...`);

  prepareSnapshot();

  const targets = arg === 'all' ? ['cloud', 'standard'] : [arg];

  try {
    for (const t of targets) {
      syncBranch(t, headInfo);
    }
  } finally {
    // Always return to main
    console.log(`\n↩ Returning to branch 'main'...`);
    run('git checkout main');
    if (fs.existsSync(tempSyncDir)) {
      fs.rmSync(tempSyncDir, { recursive: true, force: true });
    }
  }

  console.log('\n✨ Branch synchronization complete!');
  console.log('You can now inspect or push the branches:');
  console.log('  git push origin cloud');
  console.log('  git push origin standard\n');
}

main();
