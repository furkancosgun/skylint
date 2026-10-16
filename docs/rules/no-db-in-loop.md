# `no-db-in-loop`

> **Category:** [Performance & Database](/rules/#performance) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `DBINLOOP` &nbsp;|&nbsp; **QuickFix:** No

## Description

Avoid database access inside loop iterations.

## ❌ Non-Compliant Code

```abap
DATA lt_tab TYPE STANDARD TABLE OF zskylint_dummy WITH DEFAULT KEY.
DATA ls_row TYPE zskylint_dummy.
DATA ls_key TYPE string.
LOOP AT lt_tab INTO ls_row.
  SELECT SINGLE * FROM zskylint_dummy INTO @ls_row WHERE field1 = @ls_key.
ENDLOOP.
```

## ✅ Compliant Code

```abap
DATA ls_row TYPE zskylint_dummy.
DATA ls_key TYPE string.
SELECT SINGLE * FROM zskylint_dummy INTO @ls_row WHERE field1 = @ls_key.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC DB_IN_LOOP

" Using pragma:
... ##DB_IN_LOOP.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-db-in-loop:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_DB_IN_LOOP`
* **Implementation File:** [zcl_skylint_no_db_in_loop.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_db_in_loop.clas.abap)
