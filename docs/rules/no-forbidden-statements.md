# `no-forbidden-statements`

> **Category:** [Security & Robustness](/rules/#security) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `AVOID_USE` &nbsp;|&nbsp; **QuickFix:** No

## Description

Avoid use of certain statements (BREAK, STATICS, DEFINE, EXPORT).

## ❌ Non-Compliant Code

```abap
CALL TRANSACTION 'VA01'.
LEAVE PROGRAM.
```

## ✅ Compliant Code

```abap
" In ABAP Cloud, invoke released APIs or RAP business objects instead
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC FORBIDDEN
" Or with SAP CI_ prefix:
... "#EC CI_FORBIDDEN

" Using pragma:
... ##FORBIDDEN.
" Or with SAP CI_ prefix:
... ##CI_FORBIDDEN.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-forbidden-statements:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_FORBIDDEN`
* **Implementation File:** [zcl_skylint_no_forbidden.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_forbidden.clas.abap)
