# `no-scope-leak`

> **Category:** [Anti-Patterns & Bad Practices](/rules/#anti-patterns) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `SCOPELEAK` &nbsp;|&nbsp; **QuickFix:** No

## Description

Scope of variable (avoid variable leaking outside control blocks).

## ❌ Non-Compliant Code

```abap
DATA lv_flag TYPE abap_bool.
IF lv_flag = abap_true.
DATA lv_inner TYPE i.
ENDIF.
lv_inner = 1.
```

## ✅ Compliant Code

```abap
DATA lv_val TYPE i.
lv_val = 1.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC SCOPE_LEAK

" Using pragma:
... ##SCOPE_LEAK.
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
