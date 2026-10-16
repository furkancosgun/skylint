# `merge-nested-ifs`

> **Category:** [Clean ABAP & Modern Syntax](/rules/#clean-abap) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `NESTEDIF` &nbsp;|&nbsp; **QuickFix:** No

## Description

Detect consecutive nested IF blocks that can be merged with AND.

## ❌ Non-Compliant Code

```abap
IF is_connected( ).
  IF has_permission( ).
    execute( ).
  ENDIF.
ENDIF.
```

## ✅ Compliant Code

```abap
IF is_connected( ) AND has_permission( ).
  execute( ).
ENDIF.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC MERGE_IFS
" Or with SAP CI_ prefix:
... "#EC CI_MERGE_IFS

" Using pragma:
... ##MERGE_IFS.
" Or with SAP CI_ prefix:
... ##CI_MERGE_IFS.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  merge-nested-ifs:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_MERGE_IFS`
* **Implementation File:** [zcl_skylint_pref_merge_ifs.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_merge_ifs.clas.abap)
