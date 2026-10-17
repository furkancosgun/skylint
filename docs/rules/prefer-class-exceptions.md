# Prefer Class-Based Exceptions over Classic EXCEPTIONS

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="Finding: CLASS_EXC" />
</div>

## 📖 Description

Prefer Class-Based Exceptions over Classic EXCEPTIONS.

> **ATC Finding Message:** `Prefer class-based exceptions (RAISING) over classic EXCEPTIONS`

## 🧠 Rationale & Best Practices

Classic non-class exceptions (set via `sy-subrc`) lack stack traces, cannot carry context data, and cannot be propagated up call stacks cleanly. Use class-based exceptions (`CX_ROOT` subclasses).

## ❌ Non-Compliant Code

```abap
METHODS execute EXCEPTIONS not_found failed.
```

## ✅ Compliant Code

```abap
METHODS execute RAISING cx_not_found cx_failed.
```

## 🛠️ CLI / CI Configuration (`skylint.yaml`)

```yaml
checks:
  prefer-class-exceptions:
    enabled: true
    severity: warning
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC CLASS_EXC
" Or with SAP CI_ prefix:
... "#EC CI_CLASS_EXC

" Using pragma:
... ##CLASS_EXC.
" Or with SAP CI_ prefix:
... ##CI_CLASS_EXC.
```

## 🔍 ABAP Implementation Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_CLASS_EXC`
* **Finding Code:** `CLASS_EXC`
* **Implementation File:** [zcl_skylint_pref_class_exc.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_class_exc.clas.abap)
