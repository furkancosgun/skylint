# Verify sy-subrc Promptly After System Calls

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="Finding: CHECKSUBRC" />
</div>

## Overview

Check sy-subrc after DB, table and string operations.

> **ATC Finding Message:** `Check sy-subrc after SELECT SINGLE, READ, AUTHORITY-CHECK, FIND, SEARCH`

## Rationale

Statements that set `sy-subrc` (such as `SELECT SINGLE`, `READ TABLE`, `AUTHORITY-CHECK`, `ASSIGN`) must have their return code verified immediately before invoking unrelated statements.

## Transformation

```diff
- SELECT SINGLE * FROM /dmo/customer WHERE customer_id = @lv_id INTO @ls_customer.
- process_customer( ls_customer ). " sy-subrc is never checked
+ SELECT SINGLE * FROM /dmo/customer WHERE customer_id = @lv_id INTO @ls_customer.
+ IF sy-subrc = 0.
+   process_customer( ls_customer ).
+ ENDIF.
```

### ✕ Non-Compliant

```abap
SELECT SINGLE * FROM /dmo/customer WHERE customer_id = @lv_id INTO @ls_customer.
process_customer( ls_customer ). " sy-subrc is never checked
```

### ✓ Compliant

```abap
SELECT SINGLE * FROM /dmo/customer WHERE customer_id = @lv_id INTO @ls_customer.
IF sy-subrc = 0.
  process_customer( ls_customer ).
ENDIF.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description |
|---|---|:---:|---|
| `CHECK_SELECT_SINGLE` | `Boolean` | `true` | Configurable attribute for require-subrc-check |
| `CHECK_READ_TABLE` | `Boolean` | `true` | Configurable attribute for require-subrc-check |
| `CHECK_AUTHORITY_CHECK` | `Boolean` | `true` | Configurable attribute for require-subrc-check |
| `CHECK_FIND_SEARCH` | `Boolean` | `true` | Configurable attribute for require-subrc-check |
| `CHECK_ASSIGN` | `Boolean` | `true` | Configurable attribute for require-subrc-check |

## CLI & CI/CD Configuration

```yaml
checks:
  require-subrc-check:
    enabled: true
    severity: warning
    attributes:
      CHECK_SELECT_SINGLE: true
      CHECK_READ_TABLE: true
      CHECK_AUTHORITY_CHECK: true
      CHECK_FIND_SEARCH: true
      CHECK_ASSIGN: true
```

## Suppression

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC CHECK_SUBRC
" Or with SAP CI_ prefix:
... "#EC CI_CHECK_SUBRC

" Using pragma:
... ##CHECK_SUBRC.
" Or with SAP CI_ prefix:
... ##CI_CHECK_SUBRC.
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_CHECK_SUBRC`
* **Finding Code:** `CHECKSUBRC`
* **Implementation File:** [zcl_skylint_check_subrc.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_check_subrc.clas.abap)
