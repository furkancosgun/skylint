---
title: "Modernize READ TABLE (Table Expressions & line_exists)"
description: "Modernize READ TABLE (Table Expressions & line_exists) - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-read-table, clean-abap"
category: "clean-abap"
ruleId: "pref-read-table"
---

# Modernize READ TABLE (Table Expressions & line_exists)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_TAB_EXPR" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Modernize READ TABLE (table expressions & line_exists).

> **ATC Finding Messages:**
> - `Prefer table expression itab[ ... ] over READ TABLE`
> - `Prefer line_exists( ... ) instead of READ TABLE ... TRANSPORTING NO FIELDS`

## Rationale

Legacy READ TABLE requires procedural work areas, field symbols, and error-prone sy-subrc checks. Modern ABAP provides table expressions (itab[ ... ]) for direct value and reference retrieval, and line_exists( ... ) for existence checks. Modernizing READ TABLE simplifies code, avoids mutable intermediary variables, and embeds seamlessly into functional expressions.

### Non-Compliant

```abap
READ TABLE lt_orders INTO ls_order WITH KEY order_id = lv_id.
READ TABLE lt_customers TRANSPORTING NO FIELDS WITH KEY customer_id = lv_id.
IF sy-subrc = 0.
  process( ).
ENDIF.
```

### Compliant

```abap
ls_order = VALUE #( lt_orders[ order_id = lv_id ] OPTIONAL ).
IF line_exists( lt_customers[ customer_id = lv_id ] ).
  process( ).
ENDIF.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_TAB_EXPR` | `Boolean` | <code>true</code> | Suggest table expressions (lt_tab[ ... ]) instead of READ TABLE INTO |
| `CHECK_LINE_EXISTS` | `Boolean` | <code>true</code> | Suggest line_exists( ) instead of READ TABLE TRANSPORTING NO FIELDS |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_TAB_EXPR

" SAP CI_ prefix format:
... "#EC CI_PREF_TAB_EXPR
```


## Related Rules

* [Prefer lines( ) over DESCRIBE TABLE](/rules/pref-lines) — <code>#EC PREF_LINES</code>
* [Avoid WITH DEFAULT KEY](/rules/no-default-key) — <code>#EC NO_DEFAULT_KEY</code>
* [Prefer ASSIGNING over LOOP INTO Copy Targets](/rules/no-loop-into) — <code>#EC NO_LOOP_INTO</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_READ_TABLE`
* **Implementation File:** [#skyl#cl_pref_read_table.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_read_table.clas.abap)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_READ_TABLE&title=%5BBug%5D%3A%20Issue%20in%20pref-read-table)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-read-table)**
