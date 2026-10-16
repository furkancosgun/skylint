# `no-select-star`

> **Category:** [Performance & Database](/rules/#performance) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `SELECTSTAR` &nbsp;|&nbsp; **QuickFix:** No

## Description

Select performance (Avoid SELECT * and SELECT ... ENDSELECT).

## ❌ Non-Compliant Code

```abap
SELECT * FROM zskylint_dummy INTO @DATA(ls_row).
ENDSELECT.
```

## ✅ Compliant Code

```abap
DATA lt_tab TYPE STANDARD TABLE OF zskylint_dummy WITH DEFAULT KEY.
SELECT field1 FROM zskylint_dummy INTO TABLE @lt_tab.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC SELECT_STAR

" Using pragma:
... ##SELECT_STAR.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-select-star:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_SELECT_STAR`
* **Implementation File:** [zcl_skylint_no_select_star.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_select_star.clas.abap)
