---
description: "Detect 7.40+ syntax incompatible with downport targets"
---

# Check Downport Compatibility (7.40+ Modern Constructs)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="cloud-readiness" />
  <Badge type="danger" text="#EC DOWNPORT_COMPAT" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Detect 7.40+ syntax incompatible with downport targets.

> **ATC Finding Message:** `Modern ABAP construct is incompatible with downport target release`

## Rationale

Flags modern 7.40+ ABAP constructs (constructor expressions, table expressions, inline declarations, string templates, and method chaining) when targeting legacy SAP NetWeaver downport releases (e.g. 7.00, 7.31). All checks default to disabled so modern workflows remain unaffected.

### Non-Compliant

```abap
DATA(lv_val) = VALUE #( lt_data[ 1 ]-field OPTIONAL ).
```

### Compliant

```abap
DATA lv_val TYPE string.
READ TABLE lt_data INTO ls_data INDEX 1.
IF sy-subrc = 0.
  lv_val = ls_data-field.
ENDIF.
```

## Transformation

```diff
- DATA(lv_val) = VALUE #( lt_data[ 1 ]-field OPTIONAL ).
+ DATA lv_val TYPE string.
+ READ TABLE lt_data INTO ls_data INDEX 1.
+ IF sy-subrc = 0.
+   lv_val = ls_data-field.
+ ENDIF.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value |
|---|---|:---:|
| `CHECK_CONSTRUCTORS` | `Boolean` | <code>false</code> |
| `CHECK_TABLE_EXPR` | `Boolean` | <code>false</code> |
| `CHECK_INLINE_DECL` | `Boolean` | <code>false</code> |
| `CHECK_STRING_TEMPL` | `Boolean` | <code>false</code> |
| `CHECK_CHAINING` | `Boolean` | <code>false</code> |
| `CHECK_EMPTY_KEY` | `Boolean` | <code>false</code> |
| `CHECK_CALC_ASSIGN` | `Boolean` | <code>false</code> |
| `CHECK_LINE_FUNCS` | `Boolean` | <code>false</code> |
| `CHECK_STRICT_SQL` | `Boolean` | <code>false</code> |
| `CHECK_RAISE_MESSAGE` | `Boolean` | <code>false</code> |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC DOWNPORT_COMPAT

" SAP CI_ prefix format:
... "#EC CI_DOWNPORT_COMPAT
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_DOWNPORT`
* **Implementation File:** [zcl_skylint_pref_downport.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_downport.clas.abap)
