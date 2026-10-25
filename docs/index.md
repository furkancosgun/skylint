---
layout: home

hero:
  name: "Skylint"
  text: "Enterprise Clean ABAP Linter"
  tagline: "135 Native ATC Rules for Clean ABAP & Cloud-Ready Systems. 100% ABAP Cloud, zero legacy baggage, instant QuickFixes."
  image:
    src: /logo.svg
    alt: Skylint Cloud Logo
  actions:
    - theme: brand
      text: Get Started
      link: /guide/getting-started
    - theme: alt
      text: Explore 135 Rules
      link: /rules/
    - theme: alt
      text: Variant Builder
      link: /variant-builder

features:
  - icon:
      src: /icons/atc.svg
      alt: Native SAP ATC integration
      width: 48
      height: 48
    title: Native SAP ATC Integration
    details: Zero adapter layers. Runs directly inside SAP GUI and Eclipse ADT via if_ci_atc_check with abapGit transport.
  - icon:
      src: /icons/rules.svg
      alt: Clean ABAP rule catalog
      width: 48
      height: 48
    title: 135 Clean ABAP Rules
    details: Enforcing modern syntax, expression-based ABAP, safety boundaries, and object-oriented cleanliness.
  - icon:
      src: /icons/quickfix.svg
      alt: Automated QuickFixes
      width: 48
      height: 48
    title: Automated QuickFixes
    details: Built-in automated refactoring for modern syntax upgrades (lines, string templates, NEW #, etc.) with Ctrl + 1.
  - icon:
      src: /icons/variant.svg
      alt: ATC Variant Builder
      width: 48
      height: 48
    title: ATC Variant Builder
    details: Build custom SAP ATC check variants (.chkv.json) and tune rule parameters for SAP GUI / abapGit.
---

## Enterprise ABAP Quality Platform

Skylint transforms static code analysis for SAP ecosystems by executing directly within the standard **ABAP Test Cockpit (ATC)** framework. It enforces Clean ABAP guidelines and cloud-readiness natively inside Eclipse ADT and automated pipelines.

### Architecture & Documentation
- [Getting Started & Installation Guide](/guide/getting-started): Step-by-step setup via abapGit for SAP BTP, S/4HANA Cloud, and On-Premise.
- [SAP ATC Integration & ABAP Cloud](/guide/atc-integration): Learn why native ATC replaces legacy SCI and how to configure CI/CD.
- [ATC Variant Configuration & Parameters](/guide/configuration): Configure rule severities, parameters, and thresholds in Eclipse ADT.
- [Suppressions & Pragma Standards](/guide/suppressions): Manage intentional exceptions using standard #EC pseudo-comments and pragmas.

### Clean ABAP Rule Categories
- [Clean ABAP & Modern Syntax](/rules/#clean-abap): Modern language features, expression-oriented coding, and idiomatic practices.
- [Anti-Patterns & Bad Practices](/rules/#anti-patterns): Discouraged constructs, obsolete statements, and redundant syntax.
- [Performance & Database Optimization](/rules/#performance): Database query efficiency, buffer protection, and internal table operation guidelines.
- [Security & Robustness](/rules/#security): Authorizations, dynamic execution sanitation, error handling, and runtime safety.
- [Metrics & Complexity Limits](/rules/#metrics): Quantitative boundaries for method size, nesting depth, parameter counts, and cyclomatic complexity.

### Developer Tools & Catalogs
- [Interactive ATC Variant Builder](/variant-builder): Visually customize rules, tune thresholds, and export CHKV JSON configurations.
- [Complete Interactive Catalog](/rules/): Browse all 135 native check rules with before-and-after Clean ABAP examples.
- [GitHub Open Source Repository](https://github.com/furkancosgun/skylint): Source code, issue tracker, contributions, and community releases.
