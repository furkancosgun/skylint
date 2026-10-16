# `no-chained-assignment`

> **Category:** [Anti-Patterns & Bad Practices](/rules/#anti-patterns) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `ASSIGNCHN` &nbsp;|&nbsp; **QuickFix:** ⚡ Yes

## Description

Avoid assignment chaining (a = b = c).

## ❌ Non-Compliant Code

```abap
DATA lv_a TYPE i.
DATA lv_b TYPE i.
DATA lv_c TYPE i.
lv_a = lv_b = lv_c.
```

## ✅ Compliant Code

```abap
DATA lv_a TYPE i.
DATA lv_b TYPE i.
lv_a = lv_b.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC CHAIN_ASSIGN

" Using pragma:
... ##CHAIN_ASSIGN.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  no-chained-assignment:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_CHAIN_ASSIGN`
* **Implementation File:** [zcl_skylint_no_chain_assign.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_chain_assign.clas.abap)
