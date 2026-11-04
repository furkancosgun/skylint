---
description: "Comprehensive guide on integrating Skylint with SAP ABAP Test Cockpit (ATC), configuring Check Variants, and running automated CI/CD checks."
---

# SAP ATC Integration Guide

Skylint is an **ATC-native** static analysis engine. This guide explains how Skylint integrates into SAP's modern quality assurance infrastructure, why it exclusively targets **ABAP Test Cockpit (ATC)** instead of the legacy **Code Inspector (SCI)**, and how to set up Check Variants and CI/CD pipelines.

---

## Why ATC and NOT Classic SCI (Code Inspector)?

A critical design choice of Skylint is its exclusive adherence to **SAP's modern ATC framework** (`IF_CI_ATC_CHECK`).

### The Technical & Architectural Differences

| Dimension | Legacy Code Inspector (SCI) | Modern ABAP Test Cockpit (ATC) | Skylint Architecture |
|---|---|---|---|
| **Base Interface** | `cl_ci_check_root` | `if_ci_atc_check` | Extends `/skyl/cl_rule_base` & implements `if_ci_atc_check` |
| **ABAP Cloud Support** | **Forbidden / Not Released** | **100% Released (Contract C1)** | Native ABAP Cloud (`Language Version 5`) |
| **Tooling & IDE** | SAP GUI (Tx `SCI`, `SCII`) | Eclipse ADT (ABAP Development Tools) | Native Eclipse ADT integration |
| **QuickFix Automation** | Not supported | Native QuickFix API (`cl_ci_atc_quickfixes`) | One-click fixes via <kbd>Ctrl</kbd> + <kbd>1</kbd> |
| **Compiler Symbols** | Raw text tokens without semantics | Full symbol resolution (`compiler_references`) | Type-safe AST traversal |
| **Remote Checkability** | Complex RFC scripts | RFC & HTTPS Remote Source Providers | Built-in remote enablement (`is_remote_enabled = abap_true`) |

::: warning IMPORTANT: No Transaction SCI Support
Skylint check classes do **not** inherit from `cl_ci_check_root`. As a result, they will **not appear in transaction `SCI`**. 

Trying to run Skylint via legacy SCI is neither supported nor possible in ABAP Cloud. All configuration and execution must be performed via **Eclipse ADT** or the system transaction **`ATC`**.
:::

---

## Configuring Skylint in Eclipse ADT

In modern ABAP systems (SAP BTP ABAP Environment, S/4HANA Cloud, and S/4HANA 2022+), ATC Check Variants (`CHKV`) are ABAP repository objects created and maintained directly in **Eclipse ADT**.

Skylint ships with an out-of-the-box default variant: **`/SKYL/DEFAULT`** (located at `src/atc/(skyl)default.chkv.json`), pre-configured with all Clean ABAP rules enabled. You can use it immediately or create a tailored variant as described below.

### Step 1: Create or Open an ATC Check Variant in ADT

1. Open **Eclipse ADT** connected to your development or central check system.
2. In the *Project Explorer*, right-click your configuration package and select:  
   **New** &rarr; **Other ABAP Repository Object...**
3. In the search filter, type `ATC Check Variant` (Object Type: `CHKV`) and click **Next**.
4. Enter the details:
   - **Name:** e.g., `/SKYL/CLEAN_ABAP` or `ZCLEAN_ABAP`
   - **Description:** `Skylint Clean ABAP Quality Rules`
5. Click **Finish** and assign a transport request if prompted.

---

### Step 2: Configure Skylint Checks & Categories

1. The **ATC Check Variant Editor** opens in Eclipse ADT with a hierarchical tree view.
2. Skylint checks are registered via standard **ATC Category (`CHKC`)** and **ATC Check (`CHKO`)** objects and appear directly in the category tree:
   - **`/SKYL/CLEAN_ABAP`:** Modern syntax, expressions, and idiomatic Clean ABAP practices.
   - **`/SKYL/ANTI_PATTERNS`:** Discouraged constructs, obsolete statements, and redundant code.
   - **`/SKYL/PERFORMANCE`:** SQL query optimization, buffer protection, and internal tables.
   - **`/SKYL/SECURITY`:** Authorization checks, dynamic statement sanitization, and runtime safety.
   - **`/SKYL/METRICS`:** Complexity boundaries (method length, cyclomatic complexity, nesting depth).
3. Check the box next to any category or individual rule to enable it.
4. For each rule, you can customize:
   - **Default Severity:** Error (blocks transport), Warning (recommended refactoring), or Note.
   - **Parameters & Thresholds:** For rules with configurable bounds (such as `MAX_METHOD_LENGTH` or `MAX_NESTING_DEPTH`), select the check and adjust the parameter values in the bottom pane.
5. Save (<kbd>Ctrl</kbd> + <kbd>S</kbd>) and activate (<kbd>Ctrl</kbd> + <kbd>F3</kbd>) the ATC Check Variant.

---

### Step 3: Set Default System-Wide ATC Variant (Optional)

To enforce Skylint checks across your development team during transport release or central check runs:

#### For On-Premise & Private Cloud (SAP GUI):
1. In SAP GUI, execute transaction **`ATC`**.
2. Navigate to **ATC Administration** &rarr; **Configuration**.
3. Under **System Check Configuration**, set the **Default Check Variant** to `/SKYL/DEFAULT` (or your custom variant).
4. Enable **Check on Transport Release** if you wish to block transport requests containing priority 1 (Error) findings.

#### For SAP BTP ABAP Environment (Steampunk):
1. Use your communication scenario or gCTS quality gate configuration.
2. Set the active check variant to `/SKYL/DEFAULT` in your pipeline or quality check configuration.

---

## Running Checks in Eclipse ADT

Developers can execute Skylint checks on individual objects, entire packages, or whole software components:

### 1. Running on Current Editor
- Press <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>F2</kbd> while editing any ABAP class or program.
- Or right-click in the editor &rarr; **Run As** &rarr; **ABAP Test Cockpit**.

### 2. Running on Entire Packages / Software Components
- In *Project Explorer*, right-click the target package or project &rarr; **Run As** &rarr; **ABAP Test Cockpit With...**.
- Select the Skylint variant (e.g. `/SKYL/DEFAULT`).
- The **ATC Result View** displays all findings, grouped by rule, priority, and object.

---

## Using Automated QuickFixes (<kbd>Ctrl</kbd> + <kbd>1</kbd>)

Skylint provides automated one-click QuickFixes for dozens of rules (e.g. `prefer-lines`, `no-call-method`, `prefer-is-not`, `prefer-string-template`).

1. In the ABAP source code editor, navigate to any line decorated with an ATC warning marker.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. The popup displays the available Skylint fix (e.g., *"Replace DESCRIBE TABLE with lines()"*).
4. Press <kbd>Enter</kbd> to apply the transformation.
5. Save and re-run ATC to verify the resolution.

---

## Central & Remote ATC Scenarios

In enterprise landscapes with multiple development systems, SAP recommends a **Central ATC Check System** architecture.

Because Skylint check base classes set `remote_enablement = abap_true` and use framework data providers:
- You only need to install Skylint once on your **Central ATC Hub** (e.g., an SAP S/4HANA foundation system or SAP BTP ABAP Environment system).
- The central system can check remote target systems (even systems where Skylint is not installed) over standard RFC or HTTPS ATC communication scenarios.
- Developers working in satellite development systems receive findings in their local Eclipse ADT seamlessly.

---

## CI/CD Pipeline Automation

Skylint integrates smoothly into modern DevOps pipelines:

### 1. Project "Piper" (SAP BTP ABAP Environment Pipeline)
If your organization uses Project Piper for ABAP CI/CD:
```groovy
stage('ATC Static Analysis') {
    steps {
        abapEnvironmentRunATCCheck(
            script: this,
            atcConfig: [
                atcCheckVariant: '/SKYL/DEFAULT',
                maxSeverity: 'warning'
            ]
        )
    }
}
```

### 2. Git-Enabled CTS (gCTS) Pre-Commit Checks
When using gCTS in ABAP Cloud, you can configure an ATC quality gate in the repository settings to automatically run the Skylint variant before any commit or push is accepted.

