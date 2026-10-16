# `no-obsolete-statements`

> **Category:** [Anti-Patterns & Bad Practices](/rules/#anti-patterns) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `OBSOLETE` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Avoid obsolete statements (MOVE, REFRESH, etc.).

## ❌ Non-Compliant Code

```abap
DATA lv_a TYPE i.
DATA lv_b TYPE i.
MOVE lv_a TO lv_b.
```

## ✅ Compliant Code

```abap
DATA lv_a TYPE i.
DATA lv_b TYPE i.
lv_b = lv_a.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC OBSOLETE

" Using pragma:
... ##OBSOLETE.
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
