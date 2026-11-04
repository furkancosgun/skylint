---
title: "Replace READ TABLE with Table Expressions and line_exists"
description: "Modernize READ TABLE INTO with table expressions and READ TABLE TRANSPORTING NO FIELDS with line_exists( ) in ABAP Cloud code."
keywords: "pref-read-table, READ TABLE, table expression, line_exists, ABAP Cloud"
category: "clean-abap"
ruleId: "pref-read-table"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L266"
---

# Replace READ TABLE with Table Expressions and line_exists

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_TAB_EXPR" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L266" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Modernize READ TABLE (table expressions & line_exists).

> **ATC Finding Messages:**
> - `Prefer table expression itab[ ... ] over READ TABLE`
> - `Prefer line_exists( ... ) instead of READ TABLE ... TRANSPORTING NO FIELDS`

## Rationale

READ TABLE forces a work area or field symbol plus a sy-subrc branch before the value can be used, and the check reports PREF_TABEX for those value reads and PREF_LNEXS for existence checks with TRANSPORTING NO FIELDS. Table expressions return the row directly inside an expression and line_exists( ) makes an existence test a boolean value, so mutable helper variables and forgotten sy-subrc resets disappear. Both constructs require unique keys and throw CX_SY_ITAB_LINE_NOT_FOUND on a miss, which is why the OPTIONAL or DEFAULT addition is part of the modern replacement.

### Non-Compliant

```abap
READ TABLE lt_sales_orders INTO ls_sales_order WITH KEY order_id = lv_order_id.
IF sy-subrc = 0.
  process_order( ls_sales_order ).
ENDIF.
READ TABLE lt_customers TRANSPORTING NO FIELDS WITH KEY customer_id = lv_customer_id.
IF sy-subrc = 0.
  authorize_customer( lv_customer_id ).
ENDIF.
```

### Compliant

```abap
ls_sales_order = VALUE #( lt_sales_orders[ order_id = lv_order_id ] OPTIONAL ).
IF ls_sales_order IS NOT INITIAL.
  process_order( ls_sales_order ).
ENDIF.
IF line_exists( lt_customers[ customer_id = lv_customer_id ] ).
  authorize_customer( lv_customer_id ).
ENDIF.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_TAB_EXPR` | `Boolean` | <code>true</code> | Report READ TABLE INTO/ASSIGNING/REFERENCE INTO that can become a table expression itab[ ... ]. Disable to keep procedural value reads while existence checks are modernized. |
| `CHECK_LINE_EXISTS` | `Boolean` | <code>true</code> | Report READ TABLE and LOOP AT with TRANSPORTING NO FIELDS that can become line_exists( ). Disable if the codebase still relies on sy-subrc based existence checks. |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_TAB_EXPR

" SAP CI_ prefix format:
... "#EC CI_PREF_TAB_EXPR
```

## Finding Codes and Replacements

| Finding code | Trigger | Modern replacement |
|---|---|---|
| `PREF_TABEX` | `READ TABLE ... INTO`, `ASSIGNING` or `REFERENCE INTO` with `INDEX` or `WITH [TABLE] KEY` | `ls_line = VALUE #( itab[ ... ] OPTIONAL ).` or `ASSIGN itab[ ... ] TO <ls_line>.` |
| `PREF_LNEXS` | `READ TABLE` or `LOOP AT` with `TRANSPORTING NO FIELDS` | `IF line_exists( itab[ ... ] ).` |

`BINARY SEARCH` and `WHERE` variants are never reported: a table expression cannot reproduce their semantics. The two finding codes use their own pseudo comments, `PREF_TABLE_EXPR` and `PREF_LINE_EXISTS`, so a single case can be suppressed without silencing the whole rule. Disable `CHECK_TAB_EXPR` while a legacy work-area API is still in place and keep `CHECK_LINE_EXISTS` enabled to modernize existence checks only.


## Related Rules

* [Use lines( ) Instead of DESCRIBE TABLE LINES](/rules/pref-lines) — <code>#EC PREF_LINES</code>
* [Avoid WITH DEFAULT KEY in Internal Table Declarations](/rules/no-default-key) — <code>#EC NO_DEFAULT_KEY</code>
* [Prefer ASSIGNING Field Symbols Over LOOP INTO Copy Targets](/rules/no-loop-into) — <code>#EC NO_LOOP_INTO</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_READ_TABLE`
* **ABAP Implementation:** [/skyl/cl_pref_read_table.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_read_table.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 266)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L266)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_READ_TABLE&title=%5BBug%5D%3A%20Issue%20in%20pref-read-table)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-read-table)**
