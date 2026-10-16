# `max-inheritance-depth`

> **Category:** [Metrics & Complexity Limits](/rules/#metrics) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `DEEP_INHRT` &nbsp;|&nbsp; **QuickFix:** No

## Description

Avoid deep class inheritance hierarchies.

## ❌ Non-Compliant Code

```abap
CLASS lcl_child DEFINITION INHERITING FROM lcl_sub_parent. " Depth > 3
ENDCLASS.
```

## ✅ Compliant Code

```abap
" Favor composition over deep class inheritance hierarchies
CLASS lcl_worker DEFINITION.
  PRIVATE SECTION.
    DATA mo_engine TYPE REF TO if_engine.
ENDCLASS.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC INHERIT_DEPTH
" Or with SAP CI_ prefix:
... "#EC CI_INHERIT_DEPTH

" Using pragma:
... ##INHERIT_DEPTH.
" Or with SAP CI_ prefix:
... ##CI_INHERIT_DEPTH.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  max-inheritance-depth:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_MAX_INHERIT`
* **Implementation File:** [zcl_skylint_max_inherit.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_max_inherit.clas.abap)
