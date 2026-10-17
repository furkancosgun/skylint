# Prefer IS NOT over NOT ... IS

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="Finding: PREFERISNT" />
</div>

## 📖 Description

Prefer IS NOT over NOT ... IS.

> **ATC Finding Message:** `Use IS NOT instead of NOT ... IS`

## 🧠 Rationale & Best Practices

Writing `IF lo_ref IS NOT BOUND` or `IF lt_tab IS NOT INITIAL` mirrors natural language reading order and avoids misreading inverted expressions that start with `NOT`.

## ❌ Non-Compliant Code

```abap
IF NOT lo_instance IS BOUND.
  RETURN.
ENDIF.
```

## ✅ Compliant Code

```abap
IF lo_instance IS NOT BOUND.
  RETURN.
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
  prefer-is-not:
    enabled: true
    severity: warning
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC IS_NOT
" Or with SAP CI_ prefix:
... "#EC CI_IS_NOT

" Using pragma:
... ##IS_NOT.
" Or with SAP CI_ prefix:
... ##CI_IS_NOT.
```

## 🔍 ABAP Implementation Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_IS_NOT`
* **Finding Code:** `PREFERISNT`
* **Implementation File:** [zcl_skylint_pref_is_not.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_is_not.clas.abap)
