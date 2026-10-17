# Avoid Unnecessary Dynamic Programming Constructs

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="Finding: DYN_STUFF" />
</div>

## 📖 Description

No Dynamic Constructs (CALL, ASSIGN, CREATE, etc.).

> **ATC Finding Message:** `Avoid dynamic calls and language constructs`

## 🧠 Rationale & Best Practices

Dynamic programming (`ASSIGN (lv_var)`, `CALL METHOD (lv_method)`) disables compile-time type checking, hampers automated refactoring, and opens security vulnerabilities.

## ❌ Non-Compliant Code

```abap
CALL FUNCTION lv_func_name.
```

## ✅ Compliant Code

```abap
CALL FUNCTION 'BAPI_USER_GET_DETAIL'.
```

## 🛠️ CLI / CI Configuration (`skylint.yaml`)

```yaml
checks:
  no-dynamic-stuff:
    enabled: true
    severity: warning
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC NO_DYNAMIC
" Or with SAP CI_ prefix:
... "#EC CI_NO_DYNAMIC

" Using pragma:
... ##NO_DYNAMIC.
" Or with SAP CI_ prefix:
... ##CI_NO_DYNAMIC.
```

## 🔍 ABAP Implementation Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_DYNAMIC_STMT`
* **Finding Code:** `DYN_STUFF`
* **Implementation File:** [zcl_skylint_no_dynamic_stmt.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_dynamic_stmt.clas.abap)
