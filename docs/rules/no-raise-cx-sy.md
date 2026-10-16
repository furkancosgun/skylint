# `no-raise-cx-sy`

> **Category:** [Security & Robustness](/rules/#security) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `RAISE_SYS` &nbsp;|&nbsp; **QuickFix:** No

## Description

Avoid raising SAP internal system exceptions (cx_sy_*).

## ❌ Non-Compliant Code

```abap
RAISE EXCEPTION TYPE cx_sy_zerodivide.
```

## ✅ Compliant Code

```abap
DATA lv_clean TYPE i.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC RAISE_CX_SY

" Using pragma:
... ##RAISE_CX_SY.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-raise-cx-sy:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_RAISE_CX_SY`
* **Implementation File:** [zcl_skylint_no_raise_cx_sy.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_raise_cx_sy.clas.abap)
