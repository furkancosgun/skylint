---
description: "Detect 7.40+ syntax incompatible with downport targets"
---

# Check Downport Compatibility (7.40+ Modern Constructs)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC DOWNPORT_COMPAT" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Detect 7.40+ syntax incompatible with downport targets.

> **ATC Finding Message:** `Modern ABAP construct is incompatible with downport target release`

## Rationale

Modern ABAP constructs such as constructor expressions, table expressions, inline declarations, string templates, and functional method chaining do not compile on legacy NetWeaver releases. When a project must remain downport-compatible, these constructs silently raise the required kernel and syntax level. The check keeps that incompatibility visible by reporting each modern construct; it is disabled by default so modern development is unaffected.

### Non-Compliant

```abap
DATA(lv_name) = lt_customers[ 1 ]-name.
```

### Compliant

```abap
DATA lv_name TYPE string.
DATA ls_customer TYPE ty_customer.
READ TABLE lt_customers INTO ls_customer INDEX 1.
IF sy-subrc = 0.
  lv_name = ls_customer-name.
ENDIF.
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
