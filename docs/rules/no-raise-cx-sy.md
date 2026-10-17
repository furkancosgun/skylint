# Avoid Explicitly Raising System Exceptions (CX_SY_*)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="Finding: RAISE_SYS" />
</div>

## 📖 Description

Avoid raising SAP internal system exceptions (cx_sy_*).

> **ATC Finding Message:** `Avoid raising SAP internal system exceptions; use application exceptions`

## 🧠 Rationale & Best Practices

`cx_sy_*` exceptions are reserved exclusively for the ABAP runtime engine (e.g., divide by zero, null reference). Applications must define and raise their own custom exception hierarchies.

## ❌ Non-Compliant Code

```abap
RAISE EXCEPTION NEW cx_sy_itab_line_not_found( ).
```

## ✅ Compliant Code

```abap
RAISE EXCEPTION NEW cx_item_not_found( ).
```

## 🛠️ CLI / CI Configuration (`skylint.yaml`)

```yaml
checks:
  no-raise-cx-sy:
    enabled: true
    severity: warning
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC RAISE_CX_SY
" Or with SAP CI_ prefix:
... "#EC CI_RAISE_CX_SY

" Using pragma:
... ##RAISE_CX_SY.
" Or with SAP CI_ prefix:
... ##CI_RAISE_CX_SY.
```

## 🔍 ABAP Implementation Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_RAISE_CX_SY`
* **Finding Code:** `RAISE_SYS`
* **Implementation File:** [zcl_skylint_no_raise_cx_sy.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_raise_cx_sy.clas.abap)
