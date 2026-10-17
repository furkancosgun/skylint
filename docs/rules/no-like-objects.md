# Avoid LIKE Typing on Global Dictionary Objects

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="Finding: AVOID_LIKE" />
</div>

## 📖 Description

Avoid LIKE referencing data objects; use explicit TYPE.

> **ATC Finding Message:** `Avoid LIKE for data declarations; specify TYPE explicitly`

## 🧠 Rationale & Best Practices

Typing dictionary objects with `LIKE` is obsolete. Use `TYPE` to refer to data types and reserve `LIKE` solely for referencing local data objects in the same procedure.

## ❌ Non-Compliant Code

```abap
DATA lv_copy LIKE lv_original.
```

## ✅ Compliant Code

```abap
DATA lv_copy TYPE string.
```

## 🛠️ CLI / CI Configuration (`skylint.yaml`)

```yaml
checks:
  no-like-objects:
    enabled: true
    severity: warning
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC LIKE_OBJECTS
" Or with SAP CI_ prefix:
... "#EC CI_LIKE_OBJECTS

" Using pragma:
... ##LIKE_OBJECTS.
" Or with SAP CI_ prefix:
... ##CI_LIKE_OBJECTS.
```

## 🔍 ABAP Implementation Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_LIKE_OBJECTS`
* **Finding Code:** `AVOID_LIKE`
* **Implementation File:** [zcl_skylint_no_like_objects.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_like_objects.clas.abap)
