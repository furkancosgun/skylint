# `test-method-naming`

> **Category:** [Clean ABAP & Modern Syntax](/rules/#clean-abap) &nbsp;|&nbsp; **Severity:** `warning` &nbsp;|&nbsp; **Finding Code:** `TEST_NAME` &nbsp;|&nbsp; **QuickFix:** No

## Description

Enforce test method naming convention (TEST_, SHOULD_) in AUnit.

## ❌ Non-Compliant Code

```abap
RETURN.
```

## ✅ Compliant Code

```abap
RETURN.
```

## 🤫 Suppression & Pseudo-Comments

To suppress findings for this rule, append the pseudo-comment or pragma to the statement:

```abap
" Using pseudo-comment:
... "#EC TEST_NAME

" Using pragma:
... ##TEST_NAME.
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
