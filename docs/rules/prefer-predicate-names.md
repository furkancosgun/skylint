# Use Predicate Naming for Boolean Methods (is_, has_, can_)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="Finding: BOOL_NAME" />
</div>

## 📖 Description

Enforce predicate naming (IS_, HAS_, CAN_) on boolean methods.

> **ATC Finding Message:** `Boolean-returning method should use predicate name (IS_, HAS_, CAN_)`

## 🧠 Rationale & Best Practices

Methods returning boolean status should read like questions (`is_valid`, `has_children`, `can_execute`) so conditionals read naturally like plain English.

## ❌ Non-Compliant Code

```abap
METHODS check_active RETURNING VALUE(rv_active) TYPE abap_bool.
```

## ✅ Compliant Code

```abap
METHODS is_active RETURNING VALUE(rv_active) TYPE abap_bool.
```

## 🛠️ CLI / CI Configuration (`skylint.yaml`)

```yaml
checks:
  prefer-predicate-names:
    enabled: true
    severity: warning
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC PRED_NAME
" Or with SAP CI_ prefix:
... "#EC CI_PRED_NAME

" Using pragma:
... ##PRED_NAME.
" Or with SAP CI_ prefix:
... ##CI_PRED_NAME.
```

## 🔍 ABAP Implementation Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_PRED_NAME`
* **Finding Code:** `BOOL_NAME`
* **Implementation File:** [zcl_skylint_pref_pred_name.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_pred_name.clas.abap)
