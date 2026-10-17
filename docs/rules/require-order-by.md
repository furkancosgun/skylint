# Require ORDER BY for Deterministic SELECT Results

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="Finding: SELECT_UP" />
</div>

## Overview

SELECT UP TO 1 ROWS requires ORDER BY.

> **ATC Finding Message:** `SELECT UP TO 1 ROWS requires an explicit ORDER BY clause for determinism`

## Rationale

Selecting rows from a relational database without an explicit `ORDER BY` clause yields non-deterministic ordering that can change unpredictably between DB executions and updates.

## Transformation

```diff
- SELECT * FROM /dmo/customer UP TO 1 ROWS INTO @ls_customer.
+ SELECT * FROM /dmo/customer ORDER BY customer_id UP TO 1 ROWS INTO @ls_customer.
```

### Non-Compliant

```abap
SELECT * FROM /dmo/customer UP TO 1 ROWS INTO @ls_customer.
```

### Compliant

```abap
SELECT * FROM /dmo/customer ORDER BY customer_id UP TO 1 ROWS INTO @ls_customer.
```

## CLI & CI/CD Configuration

```yaml
checks:
  require-order-by:
    enabled: true
    severity: warning
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC ORDER_BY

" SAP CI_ prefix format:
... "#EC CI_ORDER_BY
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_ORDER_BY`
* **Finding Code:** `SELECT_UP`
* **Implementation File:** [zcl_skylint_pref_order_by.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_order_by.clas.abap)
