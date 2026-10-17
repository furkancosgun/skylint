# Require ORDER BY for Deterministic SELECT Results

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="Finding: SELECT_UP" />
</div>

## 📖 Description

SELECT UP TO 1 ROWS requires ORDER BY.

> **ATC Finding Message:** `SELECT UP TO 1 ROWS requires an explicit ORDER BY clause for determinism`

## 🧠 Rationale & Best Practices

Selecting rows from a relational database without an explicit `ORDER BY` clause yields non-deterministic ordering that can change unpredictably between DB executions and updates.

## ❌ Non-Compliant Code

```abap
SELECT * FROM /dmo/customer UP TO 1 ROWS INTO @ls_customer.
```

## ✅ Compliant Code

```abap
SELECT * FROM /dmo/customer ORDER BY customer_id UP TO 1 ROWS INTO @ls_customer.
```

## 🛠️ CLI / CI Configuration (`skylint.yaml`)

```yaml
checks:
  require-order-by:
    enabled: true
    severity: warning
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC ORDER_BY
" Or with SAP CI_ prefix:
... "#EC CI_ORDER_BY

" Using pragma:
... ##ORDER_BY.
" Or with SAP CI_ prefix:
... ##CI_ORDER_BY.
```

## 🔍 ABAP Implementation Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_ORDER_BY`
* **Finding Code:** `SELECT_UP`
* **Implementation File:** [zcl_skylint_pref_order_by.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_order_by.clas.abap)
