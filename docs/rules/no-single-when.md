# Avoid CASE with a Single WHEN Branch

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="Finding: SHORTCASE" />
</div>

## 📖 Description

Avoid short CASE constructs with only one WHEN branch; prefer IF.

> **ATC Finding Message:** `CASE statement has <= 1 WHEN branch; prefer IF`

## 🧠 Rationale & Best Practices

A `CASE` statement containing only one `WHEN` branch is unnecessarily verbose. An `IF ... ENDIF` is more concise and idiomatic.

## ❌ Non-Compliant Code

```abap
CASE lv_status.
  WHEN 'A'.
    process_a( ).
ENDCASE.
```

## ✅ Compliant Code

```abap
IF lv_status = 'A'.
  process_a( ).
ENDIF.
```

## 🛠️ CLI / CI Configuration (`skylint.yaml`)

```yaml
checks:
  no-single-when:
    enabled: true
    severity: warning
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC SINGLE_WHEN
" Or with SAP CI_ prefix:
... "#EC CI_SINGLE_WHEN

" Using pragma:
... ##SINGLE_WHEN.
" Or with SAP CI_ prefix:
... ##CI_SINGLE_WHEN.
```

## 🔍 ABAP Implementation Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_SINGLE_WHEN`
* **Finding Code:** `SHORTCASE`
* **Implementation File:** [zcl_skylint_no_single_when.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_single_when.clas.abap)
