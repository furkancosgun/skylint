<p align="center">
  <img src="docs/public/logo.svg" width="120" height="120" alt="Skylint Logo" />
</p>

<h1 align="center">Skylint</h1>

<p align="center">
  <strong>Enterprise Clean ABAP & Cloud ATC Linter Framework</strong>
</p>

<p align="center">
  <a href="https://github.com/furkancosgun/skylint/actions/workflows/ci.yml"><img src="https://github.com/furkancosgun/skylint/actions/workflows/ci.yml/badge.svg" alt="CI" /></a>
  <a href="https://skylint.org/"><img src="https://img.shields.io/badge/docs-online-blue.svg" alt="Docs" /></a>
  <a href="https://skylint.org/rules/"><img src="https://img.shields.io/badge/rules-100%2B-brightgreen.svg" alt="Rules" /></a>
  <img src="https://img.shields.io/badge/target-ABAP%20Cloud-informational.svg" alt="ABAP Cloud" />
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-yellow.svg" alt="License" /></a>
</p>

> 📖 **Full Documentation & Interactive Rule Catalog:** [https://skylint.org/](https://skylint.org/)

---

**Skylint** is an extensible, high-performance static code analysis framework for ABAP. Every check is implemented directly as a **native SAP ATC check** (`if_ci_atc_check`), enabling native execution within Eclipse ADT and SAP GUI across SAP BTP ABAP Environment, S/4HANA Cloud, and modern On-Premise systems.

---

## ⚡ Highlights

- **🏛️ Native SAP ATC Core:** Every check implements `if_ci_atc_check` directly and is discoverable by standard ATC transactions (`ATC`, `SCI`) and Eclipse ADT.
- **☁️ 100+ Clean ABAP Rules:** Comprehensive coverage across modern ABAP expressions, syntax modernizations, SQL performance, security, and clean architecture.
- **⚡ Instant QuickFixes:** Built-in QuickFix generation for rapid, automated refactoring directly from Eclipse ADT (`Ctrl + 1`).
- **🛡️ Zero-Boilerplate Architecture:** Shared base class (`zcl_skylint_check_base`) automatically manages statement iteration, checksum calculation, finding locations, and pseudo-comment suppression.
- **🚀 High-Fidelity Offline CI Harness:** Runs transpiled checks through full AST and compiler-reference resolution pipelines offline, validating 500+ test fixtures and QuickFix round-trips without requiring a live SAP backend.

---

## 📦 Installation & Setup via abapGit

Skylint is distributed as standard ABAP Cloud source code and can be imported directly into your SAP system:

1. **Clone via abapGit:**
   - Add this repository (`https://github.com/furkancosgun/skylint.git`) as an online repository in **abapGit**.
   - Pull the repository to create the core classes, checks, and generated ATC objects.
2. **Activate Objects:**
   - Activate all classes under packages `ZCL_SKYLINT_*`.
3. **Configure ATC Check Variant:**
   - Open transaction `SCI` or `ATC` in SAP GUI (or configure ATC in Eclipse ADT).
   - Create or edit an ATC Check Variant (or use the included variant `ZSKYLINT_DEFAULT`).
   - Enable the desired Skylint checks located under the Skylint category (`ZSKYLINT`).
4. **Run Checks:**
   - Run the ATC variant on your packages, programs, or classes via Eclipse ADT (`Alt + Shift + C, C`) or standard ATC runs.

---

## 📁 Repository Structure

```text
skylint/
├── src/
│   ├── core/         # Engine core: Base check class, metadata, AST & RTTI utilities
│   ├── checks/       # 100+ modular check implementations
│   └── atc/          # Generated SAP ATC objects (CHKC category, CHKO checks, CHKV variant)
├── deps/             # Local ATC framework stubs for offline abaplint validation
├── docs/             # VitePress enterprise documentation & interactive rule catalog
├── lib/              # Test harness internals, AST parser, and QuickFix validator
├── scripts/          # Generators for ATC descriptors, documentation, and metadata
├── test/
│   ├── fixtures/     # 100+ rule fixture suites (source.abap and expected.json)
│   └── run.mjs       # ATC-native offline test harness
├── abaplint.json     # ABAP Cloud validation rules
└── package.json      # NPM build, test, and documentation scripts
```

---

## 📋 Clean ABAP & Cloud Rules (100+ Rules)

Skylint enforces 100+ Clean ABAP, security, and cloud-native rules across 5 core categories.

Explore the complete interactive catalog with detailed rationales, configuration attributes, and before/after code examples:

👉 **[Browse Full Interactive Rule Catalog (https://skylint.org/rules/)](https://skylint.org/rules/)**

### Rule Categories

- **Clean ABAP & Modern Syntax** — Modern language features, expression-oriented coding, and idiomatic Clean ABAP practices.
- **Anti-Patterns & Bad Practices** — Discouraged language constructs, legacy statements, and redundant syntax.
- **Performance & Database** — Database query efficiency, buffer protection, and internal table operation guidelines.
- **Security & Robustness** — Authorizations, dynamic execution sanitation, error handling, and runtime safety.
- **Metrics & Complexity Limits** — Quantitative boundaries for method size, nesting depth, parameter counts, and cyclomatic complexity.

---

## 🛠️ Architecture & Core Components

Each check inherits from `zcl_skylint_check_base` and focuses strictly on its AST inspection logic:

```
                  ┌───────────────────────────────┐
                  │        if_ci_atc_check        │  (Standard SAP ATC Interface)
                  └───────────────▲───────────────┘
                                  │
                  ┌───────────────┴───────────────┐
                  │     zcl_skylint_check_base    │  (Procedure Loop, Locations,
                  └───────────────▲───────────────┘   Suppressions, QuickFix Context)
                                  │
     ┌────────────────────────────┼────────────────────────────┐
     │                            │                            │
┌────┴─────────────────┐ ┌────────┴──────────────┐ ┌───────────┴───────────────┐
│ zcl_skylint_ast_util │ │ zcl_skylint_rtti_util │ │ zcl_skylint_check_meta_data │
└──────────────────────┘ └───────────────────────┘ └───────────────────────────┘
```

- **`zcl_skylint_check_base`**: Base implementation of `if_ci_atc_check~run`. Exposes concise reporting methods (`report_statement`, `report_token`, `quickfix_replace`) and coordinates finding codes, severities, and pseudo-comments.
- **`zcl_skylint_ast_util`**: Robust AST inspection library providing token lookup, sequence matching (`find_token_sequence`), keyword validation with empty-reference guarantees, and statement classification.
- **`zcl_skylint_rtti_util`**: Safe ABAP Run-Time Type Identification wrapper for class hierarchy analysis (`get_super_classes`). Note: rules utilizing RTTI are configured with `remote_enablement = abap_false`.

---

## 🧪 Development & Offline Testing

Skylint includes a fully automated test harness using `@abaplint/transpiler` to run the actual transpiled ABAP checks in Node.js:

```bash
# 1. Install dependencies & fetch ATC dependencies
npm install
npm run deps

# 2. Validate ABAP Cloud syntax via abaplint
npm run lint

# 3. Transpile rules and execute all 500+ fixture assertions & QuickFix round-trips
npm test

# Run tests for a single specific check rule
node test/run.mjs prefer-lines

# Re-generate ATC objects (CHKC, CHKO, CHKV) and index registry
npm run index

# Build and preview VitePress documentation locally
npm run docs:dev
```

### QuickFix Round-Trip Verification
The test harness automatically applies every emitted QuickFix to the test fixture and re-parses the transformed source through `@abaplint/core`. If a QuickFix generates invalid ABAP code, the test suite immediately fails.

---

## 🤝 Contributing New Rules

To author a new check rule, follow the standards defined in [AGENTS.md](AGENTS.md):

1. **Check Implementation:** Create `src/checks/zcl_skylint_XXX.clas.abap` inheriting from `zcl_skylint_check_base`.
2. **Class Metadata:** Create `src/checks/zcl_skylint_XXX.clas.xml`.
3. **Fixture Suite:** Create `test/fixtures/<rule-id>/source.abap` and `test/fixtures/<rule-id>/expected.json` (target-based line assertions).
4. **Catalog Registration:** Register the check metadata and rationale in `scripts/rules-data.mjs`.
5. **Validation:** Run `npm run index` followed by `npm test` to verify 0 lint errors, green test execution, and valid QuickFix round-trips.

---

## 📄 License

This project is open-source and licensed under the [MIT License](LICENSE).
