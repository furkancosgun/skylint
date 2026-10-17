# Prefer RETURN over EXIT in Methods

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="Finding: EXITOUTLP" />
</div>

## 📖 Description

Prefer RETURN over EXIT outside loop constructs.

> **ATC Finding Message:** `Use RETURN instead of EXIT when leaving a procedure`

## 🧠 Rationale & Best Practices

In method contexts, `EXIT` can be ambiguous when placed near loops. `RETURN` explicitly indicates an immediate exit from the current processing block or method.

## ❌ Non-Compliant Code

```abap
METHOD execute.
  IF is_invalid( ).
    EXIT.
  ENDIF.
  process( ).
ENDMETHOD.
```

## ✅ Compliant Code

```abap
METHOD execute.
  IF is_invalid( ).
    RETURN.
  ENDIF.
  process( ).
ENDMETHOD.
```

## ⚡ Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## 🛠️ CLI / CI Configuration (`skylint.yaml`)

```yaml
checks:
  prefer-return:
    enabled: true
    severity: warning
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC RETURN
" Or with SAP CI_ prefix:
... "#EC CI_RETURN

" Using pragma:
... ##RETURN.
" Or with SAP CI_ prefix:
... ##CI_RETURN.
```

## 🔍 ABAP Implementation Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_RETURN`
* **Finding Code:** `EXITOUTLP`
* **Implementation File:** [zcl_skylint_pref_return.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_return.clas.abap)
