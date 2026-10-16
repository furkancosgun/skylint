# `no-me-reference`

> **Category:** [Anti-Patterns & Bad Practices](/rules/#anti-patterns) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `AVOIDME` &nbsp;|&nbsp; **QuickFix:** No

## Description

Avoid self-reference ME->.

## ❌ Non-Compliant Code

```abap
me->mv_status = c_active.
me->process_order( ).
```

## ✅ Compliant Code

```abap
mv_status = c_active.
process_order( ).
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC ME
" Or with SAP CI_ prefix:
... "#EC CI_ME

" Using pragma:
... ##ME.
" Or with SAP CI_ prefix:
... ##CI_ME.
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
