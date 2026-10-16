# `prefer-early-return`

> **Category:** [Clean ABAP & Modern Syntax](/rules/#clean-abap) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `GUARD_METH` &nbsp;|&nbsp; **QuickFix:** No

## Description

Use early RETURN guard clause instead of wrapping method in IF block.

## ❌ Non-Compliant Code

```abap
METHOD process_order.
  IF is_valid( ).
    " Entire method logic deeply nested
    execute_order( ).
  ENDIF.
ENDMETHOD.
```

## ✅ Compliant Code

```abap
METHOD process_order.
  IF NOT is_valid( ).
    RETURN.
  ENDIF.
  execute_order( ).
ENDMETHOD.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC EARLY_RETURN
" Or with SAP CI_ prefix:
... "#EC CI_EARLY_RETURN

" Using pragma:
... ##EARLY_RETURN.
" Or with SAP CI_ prefix:
... ##CI_EARLY_RETURN.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  prefer-early-return:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_EARLY_RET`
* **Implementation File:** [zcl_skylint_pref_early_ret.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_early_ret.clas.abap)
