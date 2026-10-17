# Avoid Calling Static Methods via Instance References (->)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="Finding: STATICVIAI" />
</div>

## 📖 Description

Avoid calling static methods via instance arrow (->).

> **ATC Finding Message:** `Call static method using => instead of ->`

## 🧠 Rationale & Best Practices

Calling a static method via an object reference arrow `lo_instance->static_method( )` gives the false impression that polymorphic instance dispatch is occurring. Use `cl_class=>static_method( )`.

## ❌ Non-Compliant Code

```abap
DATA lo_instance TYPE REF TO cl_helper.
lo_instance->static_method( ).
```

## ✅ Compliant Code

```abap
cl_helper=>static_method( ).
```

## ⚡ Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## 🛠️ CLI / CI Configuration (`skylint.yaml`)

```yaml
checks:
  no-static-via-instance:
    enabled: true
    severity: warning
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC STATIC_ARROW
" Or with SAP CI_ prefix:
... "#EC CI_STATIC_ARROW

" Using pragma:
... ##STATIC_ARROW.
" Or with SAP CI_ prefix:
... ##CI_STATIC_ARROW.
```

## 🔍 ABAP Implementation Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_STATIC_ARROW`
* **Finding Code:** `STATICVIAI`
* **Implementation File:** [zcl_skylint_no_static_arrow.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_static_arrow.clas.abap)
