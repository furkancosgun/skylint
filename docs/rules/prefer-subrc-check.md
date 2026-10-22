---
description: "Check sy-subrc after DB, table and string operations"
---

# Verify sy-subrc Promptly After System Calls

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC CHECK_SUBRC" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Check sy-subrc after DB, table and string operations.

> **ATC Finding Message:** `Check sy-subrc after SELECT SINGLE, READ, AUTHORITY-CHECK, FIND, SEARCH`

## Rationale

Statements that set `sy-subrc` (such as `SELECT SINGLE`, `READ TABLE`, `AUTHORITY-CHECK`, `ASSIGN`) must have their return code verified immediately before invoking unrelated statements.

### Non-Compliant

```abap
SELECT SINGLE * FROM /dmo/customer WHERE customer_id = @lv_id INTO @ls_customer.
process_customer( ls_customer ). " sy-subrc is never checked
```

### Compliant

```abap
SELECT SINGLE * FROM /dmo/customer WHERE customer_id = @lv_id INTO @ls_customer.
IF sy-subrc = 0.
  process_customer( ls_customer ).
ENDIF.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value |
|---|---|:---:|
| `CHECK_SELECT_SINGLE` | `Boolean` | <code>true</code> |
| `CHECK_READ_TABLE` | `Boolean` | <code>true</code> |
| `CHECK_AUTHORITY_CHECK` | `Boolean` | <code>true</code> |
| `CHECK_FIND_SEARCH` | `Boolean` | <code>true</code> |
| `CHECK_ASSIGN` | `Boolean` | <code>true</code> |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC CHECK_SUBRC

" SAP CI_ prefix format:
... "#EC CI_CHECK_SUBRC
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_CHECK_SUBRC`
* **Implementation File:** [zcl_skylint_pref_check_subrc.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_check_subrc.clas.abap)
