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
  <a href="https://skylint.org/rules/"><img src="https://img.shields.io/badge/rules-200%2B%20Clean%20ABAP-brightgreen.svg" alt="Rules" /></a>
  <img src="https://img.shields.io/badge/target-ABAP%20Cloud-informational.svg" alt="ABAP Cloud" />
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-yellow.svg" alt="License" /></a>
</p>

> 📖 **Full Documentation & Interactive Rule Catalog:** [https://skylint.org/](https://skylint.org/)

---

**Skylint** is an extensible, high-performance static code analysis framework for ABAP. Every check is implemented directly as a **native SAP ATC check** (`if_ci_atc_check`), enabling native execution within Eclipse ADT and SAP GUI across SAP BTP ABAP Environment, S/4HANA Cloud, and modern On-Premise systems.

---

## ⚡ Highlights

- **🏛️ Native SAP ATC Core:** Every check implements `if_ci_atc_check` directly and is discoverable by standard ATC execution (transaction `ATC`) and Eclipse ADT.
- **☁️ Clean ABAP & Cloud Rules:** Comprehensive coverage across modern ABAP expressions, syntax modernizations, SQL performance, security, and clean architecture.
- **⚡ Instant QuickFixes:** Built-in QuickFix generation for rapid, automated refactoring directly from Eclipse ADT (`Ctrl + 1`).
- **🛡️ Zero-Boilerplate Architecture:** Shared base class (`/skyl/cl_rule_base`) automatically manages statement iteration, checksum calculation, finding locations, and pseudo-comment suppression.
- **🚀 High-Fidelity Offline CI Harness:** Runs transpiled checks through full AST and compiler-reference resolution pipelines offline, validating 1,330+ test assertions and QuickFix round-trips across 200+ rules without requiring a live SAP backend.

---

## 📦 Installation & Setup via abapGit

Skylint is developed in the official open-source namespace **`/SKYL/`** (Repair License Key: `32190681314202826278`).

Depending on your environment:

- **SAP BTP ABAP Environment (Steampunk) & S/4HANA Cloud Public Edition (ADT Only):**
  - Install the [abapGit ADT plugin](https://eclipse.abapgit.org/updatesite/) in Eclipse.
  - In the *abapGit Repositories* view, clone `https://github.com/furkancosgun/skylint.git` using your GitHub Personal Access Token (PAT).
  - Pull into target package `/SKYL/`. The namespace object (`src/#skyl#.nspc.xml`) is imported automatically.

- **SAP S/4HANA (On-Premise) & S/4HANA Cloud Private Edition (SAP GUI):**
  - Register the `/SKYL/` namespace in transaction **`SE03`** (or view `V_TRNSPACE`) with Role **`C`** (Consumer) and Repair License **`32190681314202826278`**.
  - Create package `/SKYL/` via `SE21` / ADT.
  - Clone and pull the repository using **abapGit** (transaction `ZABAPGIT` or ADT).

For comprehensive, step-by-step setup walkthroughs, see the **[Getting Started Guide](https://skylint.org/guide/getting-started)**.

---

## 📁 Repository Structure

```text
skylint/
├── src/
│   ├── core/         # Engine core: Base rule class, metadata, AST & RTTI utilities
│   ├── rules/        # Modular rule implementations (/SKYL/CL_*)
│   ├── atc/          # Generated SAP ATC objects (CHKC category, CHKO checks, CHKV variant)
│   └── #skyl#.nspc.xml # Official SAP open-source namespace object
├── deps/             # Local ATC framework stubs for offline abaplint validation
├── docs/             # VitePress enterprise documentation & interactive rule catalog
├── lib/              # Test harness internals, AST parser, and QuickFix validator
├── scripts/          # Generators for ATC descriptors, documentation, and metadata
├── test/
│   ├── fixtures/     # Rule fixture suites (source.abap and expected.json)
│   └── run.mjs       # ATC-native offline test harness
├── abaplint.json     # ABAP Cloud validation rules
└── package.json      # NPM build, test, and documentation scripts
```

---

## 📋 Clean ABAP & Cloud Rules

Skylint enforces comprehensive Clean ABAP, security, and cloud-native rules across 5 core categories.

Explore the complete interactive catalog with detailed rationales, configuration attributes, and before/after code examples:

👉 **[Browse Full Interactive Rule Catalog (https://skylint.org/rules/)](https://skylint.org/rules/)**

### Rule Categories

- **Clean ABAP & Modern Syntax** — Modern language features, expression-oriented coding, and idiomatic Clean ABAP practices.
- **Anti-Patterns & Bad Practices** — Discouraged language constructs, legacy statements, and redundant syntax.
- **Security & Robustness** — Authorizations, dynamic execution sanitation, error handling, and runtime safety.
- **Metrics & Complexity Limits** — Quantitative boundaries for method size, nesting depth, parameter counts, and cyclomatic complexity.
- **Performance & Database** — Database query efficiency, buffer protection, and internal table operation guidelines.

---

## 🛠️ Architecture & Core Components

Each check inherits from `/skyl/cl_rule_base` and focuses strictly on its AST inspection logic:

```
                  ┌───────────────────────────────┐
                  │        if_ci_atc_check        │  (Standard SAP ATC Interface)
                  └───────────────▲───────────────┘
                                  │
                  ┌───────────────┴───────────────┐
                  │     /skyl/cl_rule_base    │  (Procedure Loop, Locations,
                  └───────────────▲───────────────┘   Suppressions, QuickFix Context)
                                  │
     ┌────────────────────────────┼────────────────────────────┐
     │                            │                            │
┌────┴─────────────────┐ ┌────────┴──────────────┐ ┌───────────┴───────────────┐
│ /skyl/cl_ast_util │ │ /skyl/cl_rtti_util │ │ /skyl/cl_meta_data │
└──────────────────────┘ └───────────────────────┘ └───────────────────────────┘
```

- **`/skyl/cl_rule_base`**: Base implementation of `if_ci_atc_check~run`. Exposes concise reporting methods (`report_statement`, `report_token`, `quickfix_replace`) and coordinates finding codes, severities, and pseudo-comments.
- **`/skyl/cl_ast_util`**: Robust AST inspection library providing token lookup, sequence matching (`find_token_sequence`), keyword validation with empty-reference guarantees, and statement classification.
- **`/skyl/cl_rtti_util`**: Safe ABAP Run-Time Type Identification wrapper for class hierarchy analysis (`get_super_classes`). Note: rules utilizing RTTI are configured with `remote_enablement = abap_false`.

---

## 🧪 Development & Offline Testing

Skylint includes a fully automated test harness using `@abaplint/transpiler` to run the actual transpiled ABAP checks in Node.js:

```bash
# 1. Install dependencies & fetch ATC dependencies
npm install
npm run deps

# 2. Validate ABAP Cloud syntax via abaplint
npm run lint

# 3. Transpile rules and execute all 1,300+ fixture assertions & QuickFix round-trips
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

1. **Rule Implementation:** Create `src/rules/#skyl#cl_xxx.clas.abap` inheriting from `/skyl/cl_rule_base`.
2. **Class Metadata:** Create `src/rules/#skyl#cl_xxx.clas.xml`.
3. **Fixture Suite:** Create `test/fixtures/<check-suffix>/source.abap` and `test/fixtures/<check-suffix>/expected.json` (e.g. `test/fixtures/pref_lines/`).
4. **Catalog Registration:** Register the check metadata and rationale in `scripts/rules-data.mjs`.
5. **Validation:** Run `npm run index` followed by `npm test` to verify 0 lint errors, green test execution, and valid QuickFix round-trips.

---

## 📄 License

This project is open-source and licensed under the [MIT License](LICENSE).
