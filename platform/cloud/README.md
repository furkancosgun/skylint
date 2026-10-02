# ☁️ Skylint for SAP ATC Cloud (`cloud` branch)

This branch delivers **Skylint** with native **SAP ABAP Test Cockpit (ATC) Cloud** enablement.

## 🚀 Native ATC Integration

In this branch, the base class `ZCL_SKYLINT_CHECK_BASE` natively implements `IF_CI_ATC_CHECK`.

- **First-Class ATC Rules:** Every individual check (`ZCL_SKYLINT_CHECK_001` through `ZCL_SKYLINT_CHECK_079`) is a standalone ATC check rule.
- **Selective Enablement:** You can select, deselect, and configure individual Skylint check rules inside any SAP ATC Check Variant in transaction **`SATC`** or Eclipse ADT.
- **Native Findings & QuickFixes:** Findings and automated quickfixes are dispatched directly through the native ATC Cloud APIs (`io_context->add_finding`, `io_context->add_quickfix`).

## 🎯 Target Environments

- SAP BTP, ABAP Environment (Steampunk)
- SAP S/4HANA Cloud Public Edition
- SAP S/4HANA 2020+ (Embedded Steampunk / ABAP Cloud language version)

## ⚙️ Setup

1. Import this branch using **abapGit** into your BTP / S/4HANA Cloud system.
2. In Eclipse ADT, open your ATC Check Variant (or create one).
3. Search for `ZCL_SKYLINT_CHECK_*` and enable whichever Clean ABAP rules you require for your project!
