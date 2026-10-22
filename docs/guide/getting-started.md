---
description: "Get started with Skylint, an enterprise static analysis and linter engine designed natively for ABAP Cloud and Clean ABAP with automated QuickFixes."
---

# 🚀 Getting Started with Skylint

**Skylint** is an enterprise-grade static analysis and linter engine designed natively for **ABAP Cloud** and **Clean ABAP**. It enforces modern coding standards, prevents anti-patterns, and offers automated one-click QuickFixes right inside Eclipse ADT and CI/CD pipelines.

---

## ⚡ Architectural Foundation: 100% Native ATC

Skylint is engineered from the ground up for the modern ABAP ecosystem:
- **ATC-Native Core:** Every check rule implements SAP's released public interface [`IF_CI_ATC_CHECK`](https://help.sap.com/doc/abapdocu_cp_index_htm/cloud/en-US/index.htm?file=if_ci_atc_check.htm).
- **ABAP Cloud Compliant:** Fully compatible with Language Version 5 (ABAP Cloud), SAP BTP ABAP Environment (Steampunk), SAP S/4HANA Cloud (Public & Private Editions), and S/4HANA 2022+ On-Premise.
- **No Legacy SCI (Code Inspector):** Skylint intentionally **does not support** the legacy Code Inspector (`cl_ci_check_root` / transaction `SCI`). SCI is obsolete in ABAP Cloud and lacks modern compiler symbol resolution, AST unrolling, and native ADT QuickFix capabilities.

---

## 📦 Installation & Setup

Skylint is installed directly into your SAP system as native ATC checks via abapGit:

1. **Prerequisites:**
   - SAP BTP ABAP Environment, SAP S/4HANA Cloud, or SAP S/4HANA 2022+ On-Premise.
   - [abapGit](https://abapgit.org/) installed in your development system.
   - ABAP Development Tools (ADT) installed in Eclipse.

2. **Clone Repository:**
   - Open the **abapGit** repository manager in your SAP system.
   - Create an online repository pointing to:
     ```
     https://github.com/furkancosgun/skylint.git
     ```
   - Target package: e.g., `ZSKYLINT` (or your organization's custom package namespace).
   - Pull the `main` branch into your system and activate all objects.

3. **Verify Installation:**
   - In Eclipse ADT, search for classes prefixed with `ZCL_SKYLINT_`.
   - All check classes inherit from `ZCL_SKYLINT_CHECK_BASE` and are immediately ready for ATC variant assignment.

---

## 🛠️ The Developer Workflow in Eclipse ADT

Once installed in your SAP system and configured in an ATC Check Variant:

1. **Trigger ATC Run:**
   - Open any ABAP Class, Interface, or Program in Eclipse ADT.
   - Press <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>F2</kbd> (or right-click &rarr; **Run As** &rarr; **ABAP Test Cockpit**).

2. **Inspect Findings:**
   - Findings appear instantly in the **ATC Result View** grouped by priority (Error, Warning, Note).
   - Double-clicking a finding navigates directly to the offending line and token.

3. **Apply QuickFix:**
   - For checks supporting automated fixes (e.g. `prefer-lines`, `prefer-is-not`, `no-call-method`), press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist) on the flagged line.
   - Select the Skylint QuickFix recommendation to instantly rewrite the code into Clean ABAP.

---

## 🧭 Next Steps

- [SAP ATC Integration Guide](/guide/atc-integration): Learn how to configure ATC Check Variants and CI/CD pipelines.
- [Configuration Reference (ATC Check Variants)](/guide/configuration): Customize rule severities, parameters, and thresholds.
- [Suppressions & Pragmas](/guide/suppressions): How to suppress intentional violations using `#EC` and `##` pragmas.
- [Rules Catalog](/rules/): Browse all available rules with non-compliant and compliant examples.
