# 🖥️ Skylint Classic Code Inspector Adapter (`standard` branch)

This branch contains the **Classic SAP Code Inspector (SCI) & On-Premise ATC Adapter** for Skylint.

## 🚀 Overview

The `standard` branch integrates Skylint with SAP's classic Code Inspector infrastructure via `CL_CI_TEST_SCAN`.

- **Target Platforms:**
  - SAP NetWeaver AS ABAP 7.40, 7.50, 7.51, 7.52, 7.53+
  - SAP S/4HANA On-Premise & Private Cloud (Classic syntax & SCI)

## 📦 Objects

- `ZCL_SKYLINT_SCI_ADAPTER`: Inherits from `CL_CI_TEST_SCAN`, analyzes `ref_scan` structures/tokens, maps them into universal `zif_skylint_types`, and executes all Skylint check rules.

## ⚙️ How to Enable in Code Inspector / ATC

1. Import this branch using **abapGit** into your SAP system.
2. In transaction **`SCI`** (Code Inspector):
   - Open or create a Check Variant (e.g. `DEFAULT` or `ZSKYLINT`).
   - Navigate to the category **Program Constructs** (`CL_CI_CATEGORY_PROGRAM_CONSTRUCTS`).
   - Check the box for `Skylint: Clean ABAP & Security Suite`.
3. Save the variant and run Code Inspector / ATC directly from SE80, SE38, or SCI.
