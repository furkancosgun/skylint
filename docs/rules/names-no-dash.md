# `names-no-dash`

> **Category:** [Anti-Patterns & Bad Practices](/rules/#anti-patterns) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `NO_DASH` &nbsp;|&nbsp; **QuickFix:** No

## Description

No Dashes in Variable and Form Names.

## ❌ Non-Compliant Code

```abap
DATA foo-bar TYPE i.
```

## ✅ Compliant Code

```abap
DATA foobar TYPE i.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC NO_DASH
" Or with SAP CI_ prefix:
... "#EC CI_NO_DASH

" Using pragma:
... ##NO_DASH.
" Or with SAP CI_ prefix:
... ##CI_NO_DASH.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  names-no-dash:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NAMES_NO_DASH`
* **Implementation File:** [zcl_skylint_names_no_dash.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_names_no_dash.clas.abap)
