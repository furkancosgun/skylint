# `merge-nested-ifs`

> **Category:** [Clean ABAP & Modern Syntax](/rules/#clean-abap) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `NESTEDIF` &nbsp;|&nbsp; **QuickFix:** No

## Description

Detect consecutive nested IF blocks that can be merged with AND.

## ❌ Non-Compliant Code

```abap
DATA lv_a TYPE i.
DATA lv_b TYPE i.
DATA lv_c TYPE i.
IF lv_a = 1.
IF lv_b = 2.
lv_c = 3.
ENDIF.
ENDIF.
```

## ✅ Compliant Code

```abap
DATA lv_a TYPE i.
DATA lv_b TYPE i.
IF lv_a = 1.
lv_b = 2.
ENDIF.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC MERGE_IFS

" Using pragma:
... ##MERGE_IFS.
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
