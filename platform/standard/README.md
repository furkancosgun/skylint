# 🖥️ Skylint for Classic SAP Code Inspector & On-Premise ATC (`standard` branch)

This branch delivers **Skylint** with native **SAP Code Inspector (SCI)** and On-Premise ATC enablement.

## 🚀 Native Code Inspector Integration

In this branch, the base class `ZCL_SKYLINT_CHECK_BASE` natively inherits from `CL_CI_TEST_SCAN`.

- **First-Class Code Inspector Rules:** Every individual check (`ZCL_SKYLINT_CHECK_001` through `ZCL_SKYLINT_CHECK_079`) is a standalone Code Inspector test class.
- **Selective Enablement:** You can choose, activate, or deactivate any specific Skylint rule in your Check Variant via transaction **`SCI`**.
- **Native Findings:** Violations are reported through standard Code Inspector message handlers (`inform`).

## 🎯 Target Environments

- SAP NetWeaver AS ABAP 7.40, 7.50, 7.51, 7.52, 7.53+
- SAP S/4HANA On-Premise & Private Cloud (Classic syntax / NetWeaver runtime)

## ⚙️ Setup

1. Import this branch using **abapGit** into your SAP NetWeaver / S/4HANA system.
2. In transaction **`SCI`** (Code Inspector):
   - Open or create a Check Variant (e.g. `DEFAULT` or `ZSKYLINT`).
   - Navigate to category **Program Constructs** (`CL_CI_CATEGORY_PROGRAM_CONSTRUCTS`).
   - Select the desired `ZCL_SKYLINT_CHECK_*` rules.
3. Save the variant and execute Code Inspector from SE80, SE38, or SCI.
