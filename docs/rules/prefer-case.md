# Prefer CASE over Multiple IF / ELSEIF on the Same Variable

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="Finding: USE_CASE" />
</div>

## 📖 Description

Change IF to CASE when checking the same variable against multiple values.

> **ATC Finding Message:** `Multiple ELSEIF branches check the same variable; use CASE instead`

## 🧠 Rationale & Best Practices

When branching on multiple values of a single variable, `CASE ... WHEN` is more readable, structured, and performant than a chain of `ELSEIF` statements.

## ❌ Non-Compliant Code

```abap
IF lv_type = 'A'.
  process_a( ).
ELSEIF lv_type = 'B'.
  process_b( ).
ELSEIF lv_type = 'C'.
  process_c( ).
ENDIF.
```

## ✅ Compliant Code

```abap
CASE lv_type.
  WHEN 'A'.
    process_a( ).
  WHEN 'B'.
    process_b( ).
  WHEN 'C'.
    process_c( ).
ENDCASE.
```

## ⚙️ Configurable Parameters (ATC Variant / Profile)

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description |
|---|---|:---:|---|
| `MIN_BRANCHES` | `Integer / String` | `3` | Configurable attribute for prefer-case |

## 🛠️ CLI / CI Configuration (`skylint.yaml`)

```yaml
checks:
  prefer-case:
    enabled: true
    severity: warning
    attributes:
      MIN_BRANCHES: 3
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC PREF_CASE
" Or with SAP CI_ prefix:
... "#EC CI_PREF_CASE

" Using pragma:
... ##PREF_CASE.
" Or with SAP CI_ prefix:
... ##CI_PREF_CASE.
```

## 🔍 ABAP Implementation Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_CASE`
* **Finding Code:** `USE_CASE`
* **Implementation File:** [zcl_skylint_pref_case.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_case.clas.abap)
