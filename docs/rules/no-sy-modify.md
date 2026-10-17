# Avoid Modifying System Fields (sy-*)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="Finding: SYS_VAR_MD" />
</div>

## 📖 Description

Avoid sy-* System Variable Modification.

> **ATC Finding Message:** `Avoid modifying system fields (sy-*); system variables are read-only`

## 🧠 Rationale & Best Practices

System fields like `sy-subrc`, `sy-tabix`, and `sy-index` are managed exclusively by the ABAP runtime. Writing to them manually undermines system integrity and masks actual execution results.

## ❌ Non-Compliant Code

```abap
sy-subrc = 0.
sy-tabix = 1.
```

## ✅ Compliant Code

```abap
" Pass explicit return values or flags instead of modifying system variables (sy-*)
rv_success = abap_true.
```

## 🛠️ CLI / CI Configuration (`skylint.yaml`)

```yaml
checks:
  no-sy-modify:
    enabled: true
    severity: warning
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC SY_MODIFY
" Or with SAP CI_ prefix:
... "#EC CI_SY_MODIFY

" Using pragma:
... ##SY_MODIFY.
" Or with SAP CI_ prefix:
... ##CI_SY_MODIFY.
```

## 🔍 ABAP Implementation Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_SY_MODIFY`
* **Finding Code:** `SYS_VAR_MD`
* **Implementation File:** [zcl_skylint_no_sy_modify.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_sy_modify.clas.abap)
