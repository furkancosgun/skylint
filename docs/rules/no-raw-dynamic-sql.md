# `no-raw-dynamic-sql`

> **Category:** [Security & Robustness](/rules/#security) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `DYN_SQL` &nbsp;|&nbsp; **QuickFix:** No

## Description

Avoid dynamic SQL table or clause names without sanitization.

## ❌ Non-Compliant Code

```abap
SELECT * FROM (lv_table) WHERE (lv_where) INTO TABLE @<lt_out>.
```

## ✅ Compliant Code

```abap
SELECT * FROM /dmo/customer WHERE customer_id = @lv_id INTO TABLE @lt_customers.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC RAW_DYN_SQL
" Or with SAP CI_ prefix:
... "#EC CI_RAW_DYN_SQL

" Using pragma:
... ##RAW_DYN_SQL.
" Or with SAP CI_ prefix:
... ##CI_RAW_DYN_SQL.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-raw-dynamic-sql:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_RAW_DYN_SQL`
* **Implementation File:** [zcl_skylint_no_raw_dyn_sql.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_raw_dyn_sql.clas.abap)
