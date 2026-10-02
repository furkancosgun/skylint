# ☁️ Skylint ATC Cloud Adapter (`cloud` branch)

This branch contains the **Native SAP ATC Cloud Adapter** for Skylint.

## 🚀 Overview

The `cloud` branch adapts the portable Skylint rule catalog into SAP's modern **ABAP Test Cockpit (ATC) Cloud** framework via the `if_ci_atc_check` interface.

- **Target Platforms:**
  - SAP BTP, ABAP Environment (Steampunk)
  - SAP S/4HANA Cloud Public Edition
  - SAP S/4HANA 2020+ (Embedded Steampunk / ABAP Cloud language version)

## 📦 Objects

- `ZCL_SKYLINT_ATC_CLOUD_ADAPTER`: Implements `if_ci_atc_check`, translates ATC `if_ci_atc_source_code_provider` procedures into `zif_skylint_types`, and executes all Skylint check rules.

## ⚙️ How to Enable in ATC

1. Import this branch using **abapGit** into your BTP or S/4HANA Cloud system.
2. In transaction **`SATC`** or via the Eclipse ADT Check Variant editor:
   - Add check class `ZCL_SKYLINT_ATC_CLOUD_ADAPTER` to your ATC Check Variant (e.g. `ZSKYLINT`).
3. Run or schedule ATC inspection over your software components / packages.
