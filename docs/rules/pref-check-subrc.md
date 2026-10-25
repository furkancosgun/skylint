---
title: "Verify sy-subrc Promptly After Data Retrieval and Search"
description: "Verify sy-subrc Promptly After Data Retrieval and Search - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-check-subrc, clean-abap"
---

# Verify sy-subrc Promptly After Data Retrieval and Search

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_CHECK_SUBRC" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Check sy-subrc after DB, table and string operations.

> **ATC Finding Message:** `Check sy-subrc after SELECT SINGLE, READ, FIND, SEARCH`

## Rationale

Statements such as SELECT SINGLE, READ TABLE, FIND, and SEARCH report success through sy-subrc. If intervening statements execute before inspection, sy-subrc is overwritten and failure states are silently ignored. Check sy-subrc immediately after execution.

### Non-Compliant

```abap
SELECT SINGLE customer_id FROM /dmo/customer
  WHERE customer_id = @lv_id
  INTO @lv_customer_id.
process_customer( lv_customer_id ).
```

### Compliant

```abap
SELECT SINGLE customer_id FROM /dmo/customer
  WHERE customer_id = @lv_id
  INTO @lv_customer_id.
IF sy-subrc = 0.
  process_customer( lv_customer_id ).
ENDIF.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_SELECT_SINGLE` | `Boolean` | <code>true</code> | Require sy-subrc check after SELECT SINGLE |
| `CHECK_READ_TABLE` | `Boolean` | <code>true</code> | Require sy-subrc check after READ TABLE |
| `CHECK_FIND_SEARCH` | `Boolean` | <code>true</code> | Require sy-subrc check after FIND or SEARCH |
| `CHECK_ASSIGN` | `Boolean` | <code>true</code> | Require sy-subrc check after dynamic ASSIGN |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_CHECK_SUBRC

" SAP CI_ prefix format:
... "#EC CI_PREF_CHECK_SUBRC
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_CHECK_SUBRC`
* **Implementation File:** [zcl_skylint_pref_check_subrc.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_check_subrc.clas.abap)
