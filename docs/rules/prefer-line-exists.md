# Prefer line_exists( ) over READ TABLE TRANSPORTING NO FIELDS

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="Finding: PREFLINEX" />
</div>

## 📖 Description

Prefer line_exists( ) over READ TABLE ... TRANSPORTING NO FIELDS.

> **ATC Finding Message:** `Prefer line_exists( ... ) instead of READ TABLE ... TRANSPORTING NO FIELDS`

## 🧠 Rationale & Best Practices

`line_exists( )` clearly communicates the intent of checking table membership in a single functional expression, eliminating the boilerplate of `READ TABLE ... TRANSPORTING NO FIELDS` followed by `sy-subrc = 0`.

## ❌ Non-Compliant Code

```abap
READ TABLE lt_items TRANSPORTING NO FIELDS WITH KEY id = lv_id.
IF sy-subrc = 0.
  process( ).
ENDIF.
```

## ✅ Compliant Code

```abap
IF line_exists( lt_items[ id = lv_id ] ).
  process( ).
ENDIF.
```

## 🛠️ CLI / CI Configuration (`skylint.yaml`)

```yaml
checks:
  prefer-line-exists:
    enabled: true
    severity: warning
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC LINE_EXISTS
" Or with SAP CI_ prefix:
... "#EC CI_LINE_EXISTS

" Using pragma:
... ##LINE_EXISTS.
" Or with SAP CI_ prefix:
... ##CI_LINE_EXISTS.
```

## 🔍 ABAP Implementation Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_LINE_EXISTS`
* **Finding Code:** `PREFLINEX`
* **Implementation File:** [zcl_skylint_pref_line_exists.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_line_exists.clas.abap)
