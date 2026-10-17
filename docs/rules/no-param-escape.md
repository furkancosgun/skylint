# Avoid Reassigning Importing Parameters

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="Finding: PARAM_ESCP" />
</div>

## 📖 Description

Detect unnecessary exclamation mark parameter escape (!iv_param).

> **ATC Finding Message:** `Escape params with ! only on keyword clash`

## 🧠 Rationale & Best Practices

Importing parameters should be treated as immutable inputs. Modifying them inside the method leads to unexpected side effects and debugging difficulties.

## ❌ Non-Compliant Code

```abap
METHODS process IMPORTING !iv_data TYPE string.
```

## ✅ Compliant Code

```abap
METHODS process IMPORTING iv_data TYPE string.
```

## ⚡ Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## 🛠️ CLI / CI Configuration (`skylint.yaml`)

```yaml
checks:
  no-param-escape:
    enabled: true
    severity: warning
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC PARAM_ESCAPE
" Or with SAP CI_ prefix:
... "#EC CI_PARAM_ESCAPE

" Using pragma:
... ##PARAM_ESCAPE.
" Or with SAP CI_ prefix:
... ##CI_PARAM_ESCAPE.
```

## 🔍 ABAP Implementation Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_PARAM_ESCAPE`
* **Finding Code:** `PARAM_ESCP`
* **Implementation File:** [zcl_skylint_no_param_escape.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_param_escape.clas.abap)
