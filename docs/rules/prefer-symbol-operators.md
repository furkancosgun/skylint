# Prefer Symbol Comparison Operators (=, <>, <, >)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="Finding: PREFEROP" />
</div>

## 📖 Description

Prefer comparison operators (=, <>, <, >, <=, >=) over legacy textual keywords.

> **ATC Finding Message:** `Prefer modern comparison operators (=, <>, <, >, <=, >=) over legacy keywords`

## 🧠 Rationale & Best Practices

Text comparison operators (`EQ`, `NE`, `LT`, `GT`, `LE`, `GE`) are legacy syntax. Modern programming and Clean ABAP universally standardize on mathematical symbols (`=`, `<>`, `<`, `>`, `<=`, `>=`).

## ❌ Non-Compliant Code

```abap
IF lv_a EQ lv_b AND lv_c NE lv_d.
  process( ).
ENDIF.
```

## ✅ Compliant Code

```abap
IF lv_a = lv_b AND lv_c <> lv_d.
  process( ).
ENDIF.
```

## ⚡ Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## 🛠️ CLI / CI Configuration (`skylint.yaml`)

```yaml
checks:
  prefer-symbol-operators:
    enabled: true
    severity: warning
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC SYMBOL_OP
" Or with SAP CI_ prefix:
... "#EC CI_SYMBOL_OP

" Using pragma:
... ##SYMBOL_OP.
" Or with SAP CI_ prefix:
... ##CI_SYMBOL_OP.
```

## 🔍 ABAP Implementation Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_SYMBOL_OP`
* **Finding Code:** `PREFEROP`
* **Implementation File:** [zcl_skylint_pref_symbol_op.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_symbol_op.clas.abap)
