# `no-scope-leak`

> **Category:** [Anti-Patterns & Bad Practices](/rules/#anti-patterns) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `SCOPELEAK` &nbsp;|&nbsp; **QuickFix:** No

## Description

Scope of variable (avoid variable leaking outside control blocks).

## ❌ Non-Compliant Code

```abap
IF lv_condition = abap_true.
  DATA(lv_value) = 10.
ENDIF.
use_value( lv_value ). " Leaked outside block
```

## ✅ Compliant Code

```abap
DATA lv_value TYPE i.
IF lv_condition = abap_true.
  lv_value = 10.
ENDIF.
use_value( lv_value ).
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC SCOPE_LEAK
" Or with SAP CI_ prefix:
... "#EC CI_SCOPE_LEAK

" Using pragma:
... ##SCOPE_LEAK.
" Or with SAP CI_ prefix:
... ##CI_SCOPE_LEAK.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-scope-leak:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_SCOPE_LEAK`
* **Implementation File:** [zcl_skylint_no_scope_leak.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_scope_leak.clas.abap)
