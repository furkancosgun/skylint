# `max-params`

> **Category:** [Metrics & Complexity Limits](/rules/#metrics) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `PARAMCOUNT` &nbsp;|&nbsp; **QuickFix:** No

## Description

Method signature cleanliness (excessive parameter count).

## ❌ Non-Compliant Code

```abap
RETURN.
```

## ✅ Compliant Code

```abap
RETURN.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC MAX_PARAMS

" Using pragma:
... ##MAX_PARAMS.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  max-params:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_MAX_PARAMS`
* **Implementation File:** [zcl_skylint_max_params.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_max_params.clas.abap)
