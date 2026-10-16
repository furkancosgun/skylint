# `prefer-xsdbool`

> **Category:** [Clean ABAP & Modern Syntax](/rules/#clean-abap) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `PREFERXSDB` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Prefer xsdbool( ) expression over manual IF-ELSE assignment.

## ❌ Non-Compliant Code

```abap
DATA lv_a TYPE i.
DATA lv_b TYPE i.
DATA lv_flag TYPE abap_bool.
IF lv_a = lv_b.
lv_flag = abap_true.
ELSE.
lv_flag = abap_false.
ENDIF.
```

## ✅ Compliant Code

```abap
DATA lv_a TYPE i.
DATA lv_b TYPE i.
DATA lv_x TYPE i.
DATA lv_y TYPE i.
IF lv_a = lv_b.
lv_x = abap_true.
ELSE.
lv_y = abap_false.
ENDIF.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC XSDBOOL

" Using pragma:
... ##XSDBOOL.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  prefer-xsdbool:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_XSDBOOL`
* **Implementation File:** [zcl_skylint_pref_xsdbool.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_xsdbool.clas.abap)
