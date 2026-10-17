# Prefer Functional RETURNING Parameters

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="Finding: PREFER_RET" />
</div>

## 📖 Description

Prefer RETURNING over single EXPORTING.

> **ATC Finding Message:** `Prefer functional RETURNING parameter over single EXPORTING parameter`

## 🧠 Rationale & Best Practices

Methods with a `RETURNING` parameter can be used directly within expressions, assignments, and assertions. Prefer `RETURNING` over a single `EXPORTING` parameter.

## ❌ Non-Compliant Code

```abap
METHODS calculate
  EXPORTING ev_result TYPE i.
```

## ✅ Compliant Code

```abap
METHODS calculate
  RETURNING VALUE(rv_result) TYPE i.
```

## 🛠️ CLI / CI Configuration (`skylint.yaml`)

```yaml
checks:
  prefer-returning:
    enabled: true
    severity: warning
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC RETURNING
" Or with SAP CI_ prefix:
... "#EC CI_RETURNING

" Using pragma:
... ##RETURNING.
" Or with SAP CI_ prefix:
... ##CI_RETURNING.
```

## 🔍 ABAP Implementation Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_RETURNING`
* **Finding Code:** `PREFER_RET`
* **Implementation File:** [zcl_skylint_pref_returning.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_returning.clas.abap)
