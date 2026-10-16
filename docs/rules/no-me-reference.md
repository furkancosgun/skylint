# `no-me-reference`

> **Category:** [Anti-Patterns & Bad Practices](/rules/#anti-patterns) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `AVOIDME` &nbsp;|&nbsp; **QuickFix:** No

## Description

Avoid self-reference ME->.

## ❌ Non-Compliant Code

```abap
me->run( ).
```

## ✅ Compliant Code

```abap
DATA lo_obj TYPE REF TO zcl_skylint_test_005.
lo_obj->run( ).
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC ME

" Using pragma:
... ##ME.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-me-reference:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_ME_REFERENCE`
* **Implementation File:** [zcl_skylint_no_me_reference.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_me_reference.clas.abap)
