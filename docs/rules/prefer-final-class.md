# Design for Inheritance or Prohibit It (FINAL)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="⚡ QuickFix Ready" />
  <Badge type="danger" text="Finding: NOT_FINAL" />
</div>

## Overview

Prefer FINAL classes and methods by default.

> **ATC Finding Message:** `Classes should be marked FINAL by default unless designed for inheritance`

## Rationale

Classes not explicitly designed and documented for inheritance should be declared `FINAL`. This prevents subclassing that relies on fragile base-class implementation details.

## Transformation

```diff
- CLASS cl_customer_service DEFINITION PUBLIC CREATE PUBLIC.
-   " Class not intended for inheritance
- ENDCLASS.
+ CLASS cl_customer_service DEFINITION PUBLIC FINAL CREATE PUBLIC.
+ ENDCLASS.
```

### ✕ Non-Compliant

```abap
CLASS cl_customer_service DEFINITION PUBLIC CREATE PUBLIC.
  " Class not intended for inheritance
ENDCLASS.
```

### ✓ Compliant

```abap
CLASS cl_customer_service DEFINITION PUBLIC FINAL CREATE PUBLIC.
ENDCLASS.
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## CLI & CI/CD Configuration

```yaml
checks:
  prefer-final-class:
    enabled: true
    severity: warning
```

## Suppression

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC FINAL_CLS
" Or with SAP CI_ prefix:
... "#EC CI_FINAL_CLS

" Using pragma:
... ##FINAL_CLS.
" Or with SAP CI_ prefix:
... ##CI_FINAL_CLS.
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_FINAL_CLS`
* **Finding Code:** `NOT_FINAL`
* **Implementation File:** [zcl_skylint_pref_final_cls.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_final_cls.clas.abap)
