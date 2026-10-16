# `no-obsolete-loop-control`

> **Category:** [Anti-Patterns & Bad Practices](/rules/#anti-patterns) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `OBS_L_CTRL` &nbsp;|&nbsp; **QuickFix:** No

## Description

Avoid obsolete control statements (ON CHANGE OF, AT NEW, SUM) in LOOP.

## ❌ Non-Compliant Code

```abap
LOOP AT lt_items INTO ls_item.
  AT NEW id.
    " Obsolete control block inside LOOP
  ENDAT.
ENDLOOP.
```

## ✅ Compliant Code

```abap
LOOP AT lt_items INTO ls_item GROUP BY ( id = ls_item-id ) INTO DATA(group).
  " Modern ABAP GROUP BY
ENDLOOP.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC OBS_LOOP_CTL
" Or with SAP CI_ prefix:
... "#EC CI_OBS_LOOP_CTL

" Using pragma:
... ##OBS_LOOP_CTL.
" Or with SAP CI_ prefix:
... ##CI_OBS_LOOP_CTL.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-obsolete-loop-control:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_OBS_LOOP_CTL`
* **Implementation File:** [zcl_skylint_no_obs_loop_ctl.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_obs_loop_ctl.clas.abap)
