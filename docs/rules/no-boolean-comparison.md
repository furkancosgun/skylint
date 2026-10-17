# Avoid Comparing to abap_true / abap_false

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="Finding: BOOLCOMP" />
</div>

## 📖 Description

Avoid comparing boolean method calls to boolean literals.

> **ATC Finding Message:** `Avoid boolean comparison for method calls; call method directly`

## 🧠 Rationale & Best Practices

Predicate methods and boolean expressions evaluate directly to true or false. Comparing them explicitly (`IF is_valid( ) = abap_true`) is redundant, noisy, and unidiomatic.

## ❌ Non-Compliant Code

```abap
IF is_valid( ) = abap_true.
  execute( ).
ENDIF.
```

## ✅ Compliant Code

```abap
IF is_valid( ).
  execute( ).
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
  no-boolean-comparison:
    enabled: true
    severity: warning
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC BOOL_COMPARE
" Or with SAP CI_ prefix:
... "#EC CI_BOOL_COMPARE

" Using pragma:
... ##BOOL_COMPARE.
" Or with SAP CI_ prefix:
... ##CI_BOOL_COMPARE.
```

## 🔍 ABAP Implementation Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_BOOL_COMPARE`
* **Finding Code:** `BOOLCOMP`
* **Implementation File:** [zcl_skylint_no_bool_compare.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_bool_compare.clas.abap)
