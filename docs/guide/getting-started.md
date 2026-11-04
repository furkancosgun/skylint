---
description: "Get started with Skylint, an enterprise static analysis and linter engine designed natively for ABAP Cloud and Clean ABAP with automated QuickFixes."
---

# Getting Started with Skylint

**Skylint** is an enterprise-grade static analysis and linter engine designed natively for **ABAP Cloud** and **Clean ABAP**. It enforces modern coding standards, prevents anti-patterns, and offers automated one-click QuickFixes right inside Eclipse ADT and CI/CD pipelines.

---

## Architectural Foundation: 100% Native ATC

Skylint is engineered from the ground up for the modern ABAP ecosystem:
- **ATC-Native Core:** Every check rule implements SAP's released public interface [`IF_CI_ATC_CHECK`](https://help.sap.com/doc/abapdocu_cp_index_htm/cloud/en-US/index.htm?file=if_ci_atc_check.htm).
- **ABAP Cloud Compliant:** Fully compatible with Language Version 5 (ABAP Cloud), SAP BTP ABAP Environment (Steampunk), SAP S/4HANA Cloud (Public & Private Editions), and S/4HANA 2022+ On-Premise.
- **No Legacy SCI (Code Inspector):** Skylint intentionally **does not support** the legacy Code Inspector (`cl_ci_check_root` / transaction `SCI`). SCI is obsolete in ABAP Cloud and lacks modern compiler symbol resolution, AST unrolling, and native ADT QuickFix capabilities.

---

## Installation & Setup by SAP Environment

Depending on your SAP system architecture, follow the corresponding installation track below.

::: info Open Source Namespace Details
Skylint is developed in the dedicated namespace **`/SKYL/`**.
- **Namespace:** `/SKYL/`
- **Namespace Role:** `C` (Recipient / Consumer)
- **Repair License Key:** `32190681314202826278`
:::

---

### Track A: SAP BTP ABAP Environment (Steampunk) & S/4HANA Cloud Public Edition

In pure ABAP Cloud environments, SAP GUI (Dynpro) is not available. Classic transactions (`SE03`, `SE80`, `ZABAPGIT`) do not exist. All repository management is performed natively via **Eclipse ADT** or the **Manage Software Components** Fiori application.

#### 1. Install abapGit Plugin in Eclipse ADT
1. Open Eclipse ADT.
2. Navigate to **Help** &rarr; **Install New Software...**.
3. In the *Work with* field, paste:
   ```text
   https://eclipse.abapgit.org/updatesite/
   ```
4. Select **abapGit plugin for ABAP Development Tools (ADT)**, click **Next**, accept license agreements, and restart Eclipse.

#### 2. Clone Skylint via ADT
1. Open the abapGit view: **Window** &rarr; **Show View** &rarr; **Other...** &rarr; type `abapGit Repositories` (or press <kbd>Ctrl</kbd> + <kbd>3</kbd> / <kbd>Cmd</kbd> + <kbd>3</kbd> and search for `abapGit Repositories`).
2. Click the **`+` (Clone / Add Repository)** icon in the top-right toolbar.
3. Enter the repository details:
   - **Repository URL:** `https://github.com/furkancosgun/skylint.git`
   - **Branch:** `refs/heads/main`
4. Provide authentication credentials (GitHub username and a Personal Access Token / PAT with repository read permissions).
5. Link to your target package (e.g., `/SKYL/` under your software component).
6. Click **Finish**, then right-click the repository in the view and select **Pull** to download and activate all objects.
   > The namespace definition object (`src/#skyl#.nspc.xml`) is included in the repository and automatically deserialized by abapGit.

---

### Track B: SAP S/4HANA (On-Premise) & S/4HANA Cloud Private Edition (SAP GUI)

In On-Premise and Private Cloud systems with SAP GUI access, register the namespace first to permit object creation under `/SKYL/`.

#### 1. Register Namespace in Transaction `SE03`
1. Log on to your development system via SAP GUI.
2. Execute transaction **`SE03`** (Transport Organizer Tools).
3. Under **Administration**, double-click **Display/Change Namespaces** (or maintain table/view **`V_TRNSPACE`** via transaction `SM30`).
4. Switch to change mode and click **New Entries**:
   - **Namespace:** `/SKYL/`
   - **Namespace Role:** `C` (Recipient)
   - **Repair License:** `32190681314202826278`
   - **Short Text:** `Skylint Clean ABAP ATC Engine`
   - **Owner:** `SKYLINT`
5. Save the entry and assign a transport request if prompted.

#### 2. Create Target Package `/SKYL/`
1. Open transaction **`SE21`** (or **`SE80`** / Eclipse ADT).
2. Create the top-level package `/SKYL/` (or `/SKYL/MAIN`):
   - **Software Component:** e.g. `HOME` or your designated customer development component.
   - **Transport Layer:** Configure according to your landscape.

#### 3. Clone Repository with abapGit
1. Open abapGit (via transaction `ZABAPGIT` or program `ZABAPGIT_STANDALONE`).
2. Click **New Online** in the repository overview.
3. Enter the repository details:
   - **Git URL:** `https://github.com/furkancosgun/skylint.git`
   - **Target Package:** `/SKYL/`
   - **Branch:** `main`
4. Click **Create Online Repository**, then select **Pull** to import all classes, categories (`CHKC`), checks (`CHKO`), and variants (`CHKV`).
5. Activate all imported repository objects.

---

## Verifying the Installation

After pulling the repository:
1. In Eclipse ADT, open **Project Explorer** and inspect the `/SKYL/` package.
2. Verify that classes prefixed with `/SKYL/CL_` are present and active (e.g., `/SKYL/CL_RULE_BASE`, `/SKYL/CL_AST_UTIL`, `/SKYL/CL_PREF_LINES`).
3. Under **ABAP Test Cockpit**, verify that:
   - **ATC Categories (`CHKC`):** `/SKYL/CLEAN_ABAP`, `/SKYL/PERFORMANCE`, `/SKYL/SECURITY`, etc.
   - **ATC Checks (`CHKO`):** Native check definitions mapped to each rule.
   - **ATC Check Variants (`CHKV`):** The default variant `(skyl)default.chkv.json` is ready for execution.

---

## The Developer Workflow in Eclipse ADT

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

## Next Steps

- [SAP ATC Integration Guide](/guide/atc-integration): Learn how to configure ATC Check Variants and CI/CD pipelines.
- [Configuration Reference (ATC Check Variants)](/guide/configuration): Customize rule severities, parameters, and thresholds.
- [Suppressions & Pragmas](/guide/suppressions): How to suppress intentional violations using `#EC` and `##` pragmas.
- [Rules Catalog](/rules/): Browse all available rules with non-compliant and compliant examples.
