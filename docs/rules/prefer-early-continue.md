# `prefer-early-continue`

> **Category:** [Clean ABAP & Modern Syntax](/rules/#clean-abap) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `GUARD_LOOP` &nbsp;|&nbsp; **QuickFix:** No

## Description

Use early CONTINUE guard clause instead of wrapping loop in IF block.

## ❌ Non-Compliant Code

```abap
LOOP AT lt_items INTO ls_item.
  IF ls_item-is_active = abap_true.
    " Long nested loop body
    process_item( ls_item ).
  ENDIF.
ENDLOOP.
```

## ✅ Compliant Code

```abap
LOOP AT lt_items INTO ls_item.
  IF ls_item-is_active = abap_false.
    CONTINUE.
  ENDIF.
  process_item( ls_item ).
ENDLOOP.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC EARLY_CONTINUE
" Or with SAP CI_ prefix:
... "#EC CI_EARLY_CONTINUE

" Using pragma:
... ##EARLY_CONTINUE.
" Or with SAP CI_ prefix:
... ##CI_EARLY_CONTINUE.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  prefer-early-continue:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_EARLY_CONT`
* **Implementation File:** [zcl_skylint_pref_early_cont.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_early_cont.clas.abap)
