# Avoid Purely Static Utility Classes

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="Finding: STAT_CLASS" />
</div>

## 📖 Description

Avoid static-only classes; prefer instantiable interface-based design.

> **ATC Finding Message:** `Avoid static-only classes; declare instance methods and interfaces`

## 🧠 Rationale & Best Practices

Classes consisting entirely of static methods cannot be mocked via interfaces or subclassing during unit tests, creating rigid coupling throughout the application.

## ❌ Non-Compliant Code

```abap
CLASS cl_math_util DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    CLASS-METHODS add IMPORTING a TYPE i b TYPE i RETURNING VALUE(r) TYPE i.
    CLASS-METHODS sub IMPORTING a TYPE i b TYPE i RETURNING VALUE(r) TYPE i.
ENDCLASS.
```

## ✅ Compliant Code

```abap
CLASS cl_math_util DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_math_util.
    METHODS add IMPORTING a TYPE i b TYPE i RETURNING VALUE(r) TYPE i.
ENDCLASS.
```

## 🛠️ CLI / CI Configuration (`skylint.yaml`)

```yaml
checks:
  no-static-classes:
    enabled: true
    severity: warning
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC STATIC_CLS
" Or with SAP CI_ prefix:
... "#EC CI_STATIC_CLS

" Using pragma:
... ##STATIC_CLS.
" Or with SAP CI_ prefix:
... ##CI_STATIC_CLS.
```

## 🔍 ABAP Implementation Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_STATIC_CLS`
* **Finding Code:** `STAT_CLASS`
* **Implementation File:** [zcl_skylint_no_static_cls.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_static_cls.clas.abap)
