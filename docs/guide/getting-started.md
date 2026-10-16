# 🚀 Getting Started with Skylint

Skylint is a modern, high-performance static analysis and ATC (ABAP Test Cockpit) linter for ABAP Cloud and Clean ABAP.

## Quick Installation

### As CLI in your Node.js / CI pipeline
```bash
npm install -g skylint
# or run directly with npx
npx skylint scan ./src
```

### In SAP System via abapGit
1. Open **abapGit** in your SAP development system (SAP BTP ABAP Environment or S/4HANA Cloud / On-Premise).
2. Clone repository: `https://github.com/furkancosgun/skylint.git`
3. Pull into package `ZSKYLINT`.
4. Add check classes into your **ATC Check Variant** in transaction `SCI` or Eclipse ADT.

## Scanning Code

```bash
# Scan a directory
node scripts/lint-folder.mjs ./src

# Scan with automatic QuickFixes
node scripts/lint-folder.mjs ./src --fix

# Filter by a single rule
node scripts/lint-folder.mjs ./src --filter prefer-lines
```
