# Avoid Obsolete Inline Length Specifications (var(len))

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="Finding: PAREN_LEN" />
</div>

## 📖 Description

Avoid inline length specification in declarations.

> **ATC Finding Message:** `Avoid length in parentheses; use TYPE ... LENGTH ...`

## 🧠 Rationale & Best Practices

Specifying length in parentheses directly after a variable name (`lv_str(10) TYPE c`) is legacy syntax. Use modern explicit typing: `TYPE c LENGTH 10`.

## ❌ Non-Compliant Code

```abap
DATA lv_code(10) TYPE c.
```

## ✅ Compliant Code

```abap
DATA lv_code TYPE c LENGTH 10.
```

## ⚡ Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## 🛠️ CLI / CI Configuration (`skylint.yaml`)

```yaml
checks:
  no-inline-length:
    enabled: true
    severity: warning
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC PAREN_LEN
" Or with SAP CI_ prefix:
... "#EC CI_PAREN_LEN

" Using pragma:
... ##PAREN_LEN.
" Or with SAP CI_ prefix:
... ##CI_PAREN_LEN.
```

## 🔍 ABAP Implementation Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_INLINE_LEN`
* **Finding Code:** `PAREN_LEN`
* **Implementation File:** [zcl_skylint_no_inline_len.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_inline_len.clas.abap)
