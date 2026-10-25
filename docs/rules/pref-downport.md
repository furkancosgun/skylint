---
title: "Check Downport Compatibility (7.40+ Modern Constructs)"
description: "Check Downport Compatibility (7.40+ Modern Constructs) - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-downport, clean-abap"
category: "clean-abap"
ruleId: "pref-downport"
---

# Check Downport Compatibility (7.40+ Modern Constructs)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_DOWNPORT" />
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

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_CONSTRUCTORS` | `Boolean` | <code>false</code> | Check constructor expressions (NEW, VALUE, CORRESPONDING, COND, SWITCH) |
| `CHECK_TABLE_EXPR` | `Boolean` | <code>false</code> | Check table expressions (lt_tab[ ... ]) incompatible with legacy releases |
| `CHECK_INLINE_DECL` | `Boolean` | <code>false</code> | Check inline declarations (DATA(...), FIELD-SYMBOL(...)) |
| `CHECK_STRING_TEMPL` | `Boolean` | <code>false</code> | Check string templates (&#124;...&#124;) |
| `CHECK_CHAINING` | `Boolean` | <code>false</code> | Check functional method call chaining (lo->m1( )->m2( )) |
| `CHECK_EMPTY_KEY` | `Boolean` | <code>false</code> | Check WITH EMPTY KEY additions on internal tables |
| `CHECK_CALC_ASSIGN` | `Boolean` | <code>false</code> | Check calculation assignment operators (+=, -=, *=, /=) |
| `CHECK_LINE_FUNCS` | `Boolean` | <code>false</code> | Check built-in line functions (line_exists, line_index, lines) |
| `CHECK_STRICT_SQL` | `Boolean` | <code>false</code> | Check modern OpenSQL syntax (@ escaping and comma-separated projection) |
| `CHECK_RAISE_MESSAGE` | `Boolean` | <code>false</code> | Check modern RAISE EXCEPTION MESSAGE syntax |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_DOWNPORT

" SAP CI_ prefix format:
... "#EC CI_PREF_DOWNPORT
```


## Related Rules

* [Prefer Calculation Assignment Operators (+=, -=, *=)](/rules/pref-calc-op) — <code>#EC PREF_CALC_OP</code>
* [Prefer Symbol Comparison Operators (=, <>, <, >)](/rules/pref-symbol-op) — <code>#EC PREF_SYMBOL_OP</code>
* [Prefer the Short System Field Alias SY over SYST](/rules/pref-sy) — <code>#EC PREF_SY</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_DOWNPORT`
* **Implementation File:** [zcl_skylint_pref_downport.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_downport.clas.abap)
