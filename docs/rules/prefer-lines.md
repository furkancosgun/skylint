# Prefer lines( ) over DESCRIBE TABLE

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="Finding: DESCRIBELN" />
</div>

## 📖 Description

Prefer lines( ) built-in function over DESCRIBE TABLE ... LINES.

> **ATC Finding Message:** `Use lines( ) function instead of DESCRIBE TABLE ... LINES`

## 🧠 Rationale & Best Practices

The built-in `lines( )` function is modern, functional, and can be embedded directly into expressions and conditionals without requiring a temporary variable or the cumbersome procedural `DESCRIBE TABLE ... LINES` statement.

## ❌ Non-Compliant Code

```abap
DESCRIBE TABLE lt_customers LINES lv_count.
```

## ✅ Compliant Code

```abap
lv_count = lines( lt_customers ).
```

## ⚡ Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## 🛠️ CLI / CI Configuration (`skylint.yaml`)

```yaml
checks:
  prefer-lines:
    enabled: true
    severity: warning
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC LINES
" Or with SAP CI_ prefix:
... "#EC CI_LINES

" Using pragma:
... ##LINES.
" Or with SAP CI_ prefix:
... ##CI_LINES.
```

## 🔍 ABAP Implementation Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_LINES`
* **Finding Code:** `DESCRIBELN`
* **Implementation File:** [zcl_skylint_pref_lines.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_lines.clas.abap)
