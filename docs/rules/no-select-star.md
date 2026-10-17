# Avoid SELECT * Queries

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="Finding: SELECTSTAR" />
</div>

## Overview

Select performance (Avoid SELECT * and SELECT ... ENDSELECT).

> **ATC Finding Message:** `Avoid SELECT *; specify required columns explicitly`

## Rationale

Selecting all database columns transfers unnecessary data across the network, bypasses secondary indexes, and breaks table buffering. Always specify the explicit columns required.

## Transformation

```diff
- SELECT * FROM /dmo/customer INTO TABLE @lt_customers.
+ SELECT customer_id, first_name, last_name
+   FROM /dmo/customer
+   INTO TABLE @lt_customers.
```

### Non-Compliant

```abap
SELECT * FROM /dmo/customer INTO TABLE @lt_customers.
```

### Compliant

```abap
SELECT customer_id, first_name, last_name
  FROM /dmo/customer
  INTO TABLE @lt_customers.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description |
|---|---|:---:|---|
| `CHECK_SELECT_STAR` | `Boolean` | `true` | Configurable attribute for no-select-star |
| `CHECK_ENDSELECT` | `Boolean` | `true` | Configurable attribute for no-select-star |

## CLI & CI/CD Configuration

```yaml
checks:
  no-select-star:
    enabled: true
    severity: warning
    attributes:
      checkSelectStar: true
      checkEndselect: true
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC SELECT_STAR

" SAP CI_ prefix format:
... "#EC CI_SELECT_STAR
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_SELECT_STAR`
* **Finding Code:** `SELECTSTAR`
* **Implementation File:** [zcl_skylint_no_select_star.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_select_star.clas.abap)
