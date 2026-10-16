# `max-attributes`

> **Category:** [Metrics & Complexity Limits](/rules/#metrics) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `ATTR_COUNT` &nbsp;|&nbsp; **QuickFix:** No

## Description

Limit number of member attributes in a class (God Class smell).

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
... "#EC ATTRIBUTES

" Using pragma:
... ##ATTRIBUTES.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  max-attributes:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_MAX_ATTRIBUTES`
* **Implementation File:** [zcl_skylint_max_attributes.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_max_attributes.clas.abap)
