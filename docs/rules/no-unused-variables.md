# Eliminate Unused Local Variables and Symbols

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="Finding: UNUSED_VAR" />
</div>

## 📖 Description

Detect unused local variables and field symbols.

> **ATC Finding Message:** `Local variable or field symbol is declared but never used`

## 🧠 Rationale & Best Practices

Unused variables clutter code, confuse developers reviewing changes, and increase compilation and execution memory overhead without providing any benefit.

## ❌ Non-Compliant Code

```abap
DATA lv_temp TYPE string. " Declared but never referenced
```

## ✅ Compliant Code

```abap
" Remove unused declarations or add ##NEEDED pragma if required by interface
```

## 🛠️ CLI / CI Configuration (`skylint.yaml`)

```yaml
checks:
  no-unused-variables:
    enabled: true
    severity: warning
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC NEEDED
" Or with SAP CI_ prefix:
... "#EC CI_NEEDED

" Using pragma:
... ##NEEDED.
" Or with SAP CI_ prefix:
... ##CI_NEEDED.
```

## 🔍 ABAP Implementation Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_UNUSED_VARS`
* **Finding Code:** `UNUSED_VAR`
* **Implementation File:** [zcl_skylint_no_unused_vars.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_unused_vars.clas.abap)
