---
description: "Learn how to configure Skylint rules, severities, and thresholds via SAP ATC Check Variants (CHKV) and Eclipse ADT."
---

# Configuration Reference (ATC Check Variants)

Skylint is an **ATC-native** static analysis engine. Configuration is handled entirely through standard SAP **ATC Check Variants** (`CHKV`), both inside SAP systems via Eclipse ADT and in automated workflows.

---

## ATC Check Variant Architecture

In modern ABAP (SAP BTP ABAP Environment, SAP S/4HANA Cloud, and S/4HANA On-Premise 2022+), an ATC Check Variant (`CHKV`) is an ABAP repository object that defines:
1. **Enabled Checks:** Which check classes (`ZCL_SKYLINT_*`) are active during the inspection.
2. **Finding Severities:** The severity assigned to findings produced by each check (`error`, `warning`, `note`).
3. **Check Parameters & Thresholds:** Fine-tuned rule configurations (e.g., maximum method statements, nesting limits, allowed prefixes) defined via check attributes.

---

## Configuring Checks in Eclipse ADT

When editing an ATC Check Variant in Eclipse ADT:

### 1. Enabling and Disabling Rules
- Expand the Skylint category in the Check Variant tree.
- Check the box next to any rule (`ZCL_SKYLINT_*`) to enable it, or uncheck to disable it.

### 2. Customizing Severity Levels
For each selected check, you can override its finding severity:
- **Error:** Fails quality gates and blocks transport releases in SAP CTS/gCTS.
- **Warning:** Flags non-compliant Clean ABAP code that developers should refactor.
- **Note:** Informational suggestion or lightweight recommendation.

### 3. Check Parameters & Thresholds
Checks with configurable attributes expose a **Parameters** tab in Eclipse ADT:
- Select the check in the variant editor.
- The parameter table displays all configurable fields (such as `MAX_STATEMENTS`, `MAX_DEPTH`, `ALLOWED_PREFIXES`).
- Modify the values directly; they are persisted as part of the `CHKV` object.

---

## Default Variant (`ZSKYLINT_DEFAULT`)

Skylint includes a ready-to-use default ATC Check Variant definition located in:
```text
src/atc/zskylint_default.chkv.json
```
This variant enables all Clean ABAP rules with production-tested thresholds and standard severities.

---

## Interactive Variant Builder

Skylint provides an interactive web-based **Variant Builder** in the documentation portal:
- Navigate to the [Variant Builder](/variant-builder).
- Select the categories and rules relevant to your team.
- Adjust parameter limits and thresholds visually.
- Export the configuration as an SAP ATC Check Variant (`CHKV`) JSON definition ready for import into your repository.

