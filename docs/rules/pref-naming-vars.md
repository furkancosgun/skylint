---
title: "Enforce Local Variable and Field-Symbol Naming Conventions"
description: "Enforce Local Variable and Field-Symbol Naming Conventions - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-naming-vars, clean-abap"
---

# Enforce Local Variable and Field-Symbol Naming Conventions

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_NAMING_VARS" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Local Variable and Field-Symbol Naming Conventions.

> **ATC Finding Message:** `Local variable or field-symbol name does not match configured pattern`

## Rationale

Local variables, constants, statics, and field-symbols must follow distinct naming conventions (such as `lv_*`, `lc_*`, `sv_*`, `<ls_*>`, `<lv_*>`) to ensure clear scope boundaries, prevent unintended variable shadowing, and eliminate ambiguity during code reviews and debugging.

### Non-Compliant

```abap
DATA customer_name TYPE string.
FIELD-SYMBOLS <item> TYPE any.
```

### Compliant

```abap
DATA lv_customer_name TYPE string.
FIELD-SYMBOLS <ls_item> TYPE any.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `LOCAL_DATA` | `String` | <code>^L._.+$</code> | Regex pattern for local variables (default: ^L._.+$) |
| `LOCAL_CONST` | `String` | <code>^LC_.+$</code> | Regex pattern for local constants (default: ^LC_.+$) |
| `LOCAL_FS` | `String` | <code>^<L._.+>$</code> | Regex pattern for field-symbols (default: ^<L._.+>$) |
| `LOCAL_STATICS` | `String` | <code>^S._.+$</code> | Regex pattern for local static variables (default: ^S._.+$) |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_NAMING_VARS

" SAP CI_ prefix format:
... "#EC CI_PREF_NAMING_VARS
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_NAMING_VARS`
* **Implementation File:** [zcl_skylint_pref_naming_vars.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_naming_vars.clas.abap)
