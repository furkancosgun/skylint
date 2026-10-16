# `no-empty-fae`

> **Category:** [Performance & Database](/rules/#performance) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `FAENOCHECK` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Unsecure FOR ALL ENTRIES (Missing empty itab check).

## ❌ Non-Compliant Code

```abap
SELECT * FROM /dmo/customer
  FOR ALL ENTRIES IN @lt_orders
  WHERE customer_id = @lt_orders-customer_id
  INTO TABLE @lt_customers.
```

## ✅ Compliant Code

```abap
IF lt_orders IS NOT INITIAL.
  SELECT * FROM /dmo/customer
    FOR ALL ENTRIES IN @lt_orders
    WHERE customer_id = @lt_orders-customer_id
    INTO TABLE @lt_customers.
ENDIF.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC EMPTY_FAE
" Or with SAP CI_ prefix:
... "#EC CI_EMPTY_FAE

" Using pragma:
... ##EMPTY_FAE.
" Or with SAP CI_ prefix:
... ##CI_EMPTY_FAE.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-empty-fae:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_EMPTY_FAE`
* **Implementation File:** [zcl_skylint_no_empty_fae.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_empty_fae.clas.abap)
