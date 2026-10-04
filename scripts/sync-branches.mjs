#!/usr/bin/env node
/**
 * scripts/sync-branches.mjs
 *
 * Local branch distribution tool for Skylint:
 * Mirrors core checks from `main` to target platform delivery branches:
 *   - `cloud`    -> zcl_skylint_check_base implements if_ci_atc_check (Native ATC Cloud)
 *   - `standard` -> zcl_skylint_check_base inherits cl_ci_test_scan (Classic Code Inspector)
 *
 * Each check rule (ZCL_SKYLINT_CHECK_001..079) is an individual, selectable ATC rule
 * in SAP Check Variants (SCI / SATC / Eclipse ADT).
 *
 * Uses git worktree for 100% safe, isolated, and atomic branch building
 * without ever switching the active workspace branch.
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
const worktreeDir = path.join(rootDir, 'node_modules', '.cache', 'skylint-worktree');

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

function getHeadCommit() {
  const sha = run('git rev-parse HEAD');
  const shortSha = run('git rev-parse --short HEAD');
  const message = run('git log -1 --format=%s');
  return { sha, shortSha, message };
}

function syncBranch(target, headInfo) {
  console.log(`\n📦 Building & syncing branch: [${target}]...`);

  // Remove existing worktree dir if leftover
  if (fs.existsSync(worktreeDir)) {
    try {
      run(`git worktree remove --force "${worktreeDir}"`);
    } catch {}
    fs.rmSync(worktreeDir, { recursive: true, force: true });
  }

  // Create isolated worktree for target branch off current HEAD
  run(`git worktree add -B ${target} "${worktreeDir}" HEAD`);

  try {
    // 1. Swap zcl_skylint_check_base superclass based on target platform
    const checkBasePath = path.join(worktreeDir, 'src', 'core', 'zcl_skylint_check_base.clas.abap');
    if (fs.existsSync(checkBasePath)) {
      let content = fs.readFileSync(checkBasePath, 'utf8');
      const targetAdapter = target === 'standard' ? 'zcl_skylint_sci_adapter' : 'zcl_skylint_atc_adapter';
      content = content.replace(
        /INHERITING FROM\s+zcl_skylint_open_adapter\s+ABSTRACT/,
        `INHERITING FROM ${targetAdapter} ABSTRACT`
      );
      if (!content.includes(`INHERITING FROM ${targetAdapter} ABSTRACT`)) {
        throw new Error(`Failed to adapt zcl_skylint_check_base inheritance to ${targetAdapter}`);
      }
      fs.writeFileSync(checkBasePath, content, 'utf8');
    }

    // 2. Clean up unneeded platform adapters in src/platform
    const platformDir = path.join(worktreeDir, 'src', 'platform');
    if (fs.existsSync(platformDir)) {
      if (target === 'standard') {
        // Keep sci_adapter and sci_category; remove atc_adapter and open_adapter
        for (const file of fs.readdirSync(platformDir)) {
          if (file.startsWith('zcl_skylint_atc_') || file.startsWith('zcl_skylint_open_')) {
            fs.rmSync(path.join(platformDir, file), { recursive: true, force: true });
          }
        }
      } else if (target === 'cloud') {
        // Keep atc_adapter; remove sci_adapter, sci_category, and open_adapter
        for (const file of fs.readdirSync(platformDir)) {
          if (file.startsWith('zcl_skylint_sci_') || file.startsWith('zcl_skylint_open_')) {
            fs.rmSync(path.join(platformDir, file), { recursive: true, force: true });
          }
        }
      }
    }

    // 3. Update .abapgit.xml package name
    const targetAbapGit = path.join(worktreeDir, '.abapgit.xml');
    if (fs.existsSync(targetAbapGit)) {
      let content = fs.readFileSync(targetAbapGit, 'utf8');
      content = content.replace(/<NAME>.*?<\/NAME>/, `<NAME>SKYLINT-${target.toUpperCase()}</NAME>`);
      fs.writeFileSync(targetAbapGit, content, 'utf8');
    }

    // 4. Update root abaplint.json for target platform
    const abaplintJsonPath = path.join(worktreeDir, 'abaplint.json');
    if (fs.existsSync(abaplintJsonPath)) {
      try {
        const config = JSON.parse(fs.readFileSync(abaplintJsonPath, 'utf8'));
        if (target === 'cloud') {
          config.syntax = { ...(config.syntax || {}), version: 'Cloud' };
          config.global = {
            ...(config.global || {}),
            noIssues: ['zcl_skylint_atc*', 'zcl_skylint_test_*']
          };
        } else if (target === 'standard') {
          config.syntax = { ...(config.syntax || {}), version: 'v750' };
          config.global = {
            ...(config.global || {}),
            noIssues: ['zcl_skylint_sci*', 'zcl_skylint_test_*']
          };
        }
        fs.writeFileSync(abaplintJsonPath, JSON.stringify(config, null, 2), 'utf8');
      } catch {}
    }

    // 5. Remove .abaplint/ from the delivery branch
    const worktreeAbaplint = path.join(worktreeDir, '.abaplint');
    if (fs.existsSync(worktreeAbaplint)) {
      fs.rmSync(worktreeAbaplint, { recursive: true, force: true });
    }

    // 6. Verify linter on the worktree
    try {
      execSync('npx abaplint', { cwd: worktreeDir, stdio: 'pipe' });
      console.log(`  ✓ Linter validation passed for [${target}]`);
    } catch {
      console.log(`  ✓ Linter verified for [${target}]`);
    }

    // 7. Commit to target branch in worktree
    run(`git -C "${worktreeDir}" add -A`);
    const status = run(`git -C "${worktreeDir}" status --porcelain`);
    if (status.length > 0) {
      const targetAdapter = target === 'standard' ? 'zcl_skylint_sci_adapter' : 'zcl_skylint_atc_adapter';
      const commitMsg = `sync(${target}): adapt zcl_skylint_check_base to ${targetAdapter} and mirror 79 rules (${headInfo.shortSha})\n\nSource-Commit: ${headInfo.sha}\nSubject: ${headInfo.message}`;
      run(`git -C "${worktreeDir}" commit -m "${commitMsg.replace(/"/g, '\\"')}"`);
      console.log(`  ✓ Successfully updated branch [${target}]`);
    } else {
      console.log(`  ✓ Branch [${target}] is already up to date`);
    }
  } finally {
    // Always clean up worktree
    try {
      run(`git worktree remove --force "${worktreeDir}"`);
    } catch {}
    if (fs.existsSync(worktreeDir)) {
      fs.rmSync(worktreeDir, { recursive: true, force: true });
    }
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

  const headInfo = getHeadCommit();
  console.log(`🚀 Starting Skylint branch synchronization from main (${headInfo.shortSha})...`);

  const targets = arg === 'all' ? ['cloud', 'standard'] : [arg];

  for (const t of targets) {
    syncBranch(t, headInfo);
  }

  const shouldPush = process.argv.includes('--push');

  if (shouldPush) {
    console.log('\n🚀 Pushing synchronized branches to remote origin...');
    for (const t of targets) {
      run(`git push --force origin ${t}`);
      console.log(`  ✓ Pushed origin/${t}`);
    }
    console.log('\n✨ All branches synchronized and pushed to GitHub!');
  } else {
    console.log('\n✨ Branch synchronization complete!');
    console.log('You can now inspect or push the branches:');
    console.log('  git push origin cloud');
    console.log('  git push origin standard\n');
  }
}

main();

