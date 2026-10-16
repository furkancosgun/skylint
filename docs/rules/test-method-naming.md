# `test-method-naming`

> **Category:** [Clean ABAP & Modern Syntax](/rules/#clean-abap) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `TEST_NAME` &nbsp;|&nbsp; **QuickFix:** No

## Description

Enforce test method naming convention (TEST_, SHOULD_) in AUnit.

## ❌ Non-Compliant Code

```abap
METHODS calculate_discount FOR TESTING.
```

## ✅ Compliant Code

```abap
METHODS test_calculate_discount FOR TESTING.
" Or:
METHODS should_calculate_discount FOR TESTING.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC TEST_NAME
" Or with SAP CI_ prefix:
... "#EC CI_TEST_NAME

" Using pragma:
... ##TEST_NAME.
" Or with SAP CI_ prefix:
... ##CI_TEST_NAME.
```

## Configuration (`skylint.yaml`)

```yaml
checks:
  test-method-naming:
    enabled: true
    severity: warning
```

## ABAP Class Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_TEST_NAME`
* **Implementation File:** [zcl_skylint_pref_test_name.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_test_name.clas.abap)
