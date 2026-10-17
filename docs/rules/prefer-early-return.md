# Prefer Early Return to Reduce Nesting (Guard Clauses)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="Finding: GUARD_METH" />
</div>

## 📖 Description

Prefer early exit (RETURN or CONTINUE) instead of nested IF blocks.

> **ATC Finding Message:** `Invert IF condition and use RETURN to reduce nesting in method`

## 🧠 Rationale & Best Practices

Check preconditions and invalid states at the start of the method and return immediately. This eliminates deeply nested `IF ... ELSE` ladders.

## ❌ Non-Compliant Code

```abap
METHOD process_order.
  IF is_valid( ).
    " Entire method logic deeply nested
    execute_order( ).
  ENDIF.
ENDMETHOD.
```

## ✅ Compliant Code

```abap
METHOD process_order.
  IF NOT is_valid( ).
    RETURN.
  ENDIF.
  execute_order( ).
ENDMETHOD.
```

## 🛠️ CLI / CI Configuration (`skylint.yaml`)

```yaml
checks:
  prefer-early-return:
    enabled: true
    severity: warning
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC EARLY_RETURN
" Or with SAP CI_ prefix:
... "#EC CI_EARLY_RETURN

" Using pragma:
... ##EARLY_RETURN.
" Or with SAP CI_ prefix:
... ##CI_EARLY_RETURN.
```

## 🔍 ABAP Implementation Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_EARLY_RET`
* **Finding Code:** `GUARD_METH`
* **Implementation File:** [zcl_skylint_pref_early_ret.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_early_ret.clas.abap)
