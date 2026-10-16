# `no-obsolete-statements`

> **Category:** [Anti-Patterns & Bad Practices](/rules/#anti-patterns) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `OBSOLETE` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Avoid obsolete statements (MOVE, REFRESH, etc.).

## ❌ Non-Compliant Code

```abap
MOVE lv_src TO lv_dst.
```

## ✅ Compliant Code

```abap
lv_dst = lv_src.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC OBSOLETE
" Or with SAP CI_ prefix:
... "#EC CI_OBSOLETE

" Using pragma:
... ##OBSOLETE.
" Or with SAP CI_ prefix:
... ##CI_OBSOLETE.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-obsolete-statements:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_OBSOLETE`
* **Implementation File:** [zcl_skylint_no_obsolete.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_obsolete.clas.abap)
