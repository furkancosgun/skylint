# `prefer-return`

> **Category:** [Clean ABAP & Modern Syntax](/rules/#clean-abap) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `EXITOUTLP` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Prefer RETURN over EXIT outside loop constructs.

## ❌ Non-Compliant Code

```abap
METHOD execute.
  IF is_invalid( ).
    EXIT.
  ENDIF.
  process( ).
ENDMETHOD.
```

## ✅ Compliant Code

```abap
METHOD execute.
  IF is_invalid( ).
    RETURN.
  ENDIF.
  process( ).
ENDMETHOD.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC RETURN
" Or with SAP CI_ prefix:
... "#EC CI_RETURN

" Using pragma:
... ##RETURN.
" Or with SAP CI_ prefix:
... ##CI_RETURN.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  prefer-return:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_RETURN`
* **Implementation File:** [zcl_skylint_pref_return.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_return.clas.abap)
