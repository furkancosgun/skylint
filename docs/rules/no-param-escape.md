# `no-param-escape`

> **Category:** [Clean ABAP & Modern Syntax](/rules/#clean-abap) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `PARAM_ESCP` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Detect unnecessary exclamation mark parameter escape (!iv_param).

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
... "#EC PARAM_ESCAPE

" Using pragma:
... ##PARAM_ESCAPE.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-param-escape:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_PARAM_ESCAPE`
* **Implementation File:** [zcl_skylint_no_param_escape.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_param_escape.clas.abap)
