# `prefer-string-template`

> **Category:** [Clean ABAP & Modern Syntax](/rules/#clean-abap) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `CONCATSTR` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Prefer string templates over CONCATENATE.

## ❌ Non-Compliant Code

```abap
CONCATENATE 'Hello' iv_name INTO lv_greeting SEPARATED BY space.
```

## ✅ Compliant Code

```abap
lv_greeting = |Hello { iv_name }|.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC STR_TMPL
" Or with SAP CI_ prefix:
... "#EC CI_STR_TMPL

" Using pragma:
... ##STR_TMPL.
" Or with SAP CI_ prefix:
... ##CI_STR_TMPL.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  prefer-string-template:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_STR_TMPL`
* **Implementation File:** [zcl_skylint_pref_str_tmpl.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_str_tmpl.clas.abap)
