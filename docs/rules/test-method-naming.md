# Follow Clean Naming for Unit Test Methods

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="Finding: TEST_NAME" />
</div>

## 📖 Description

Enforce test method naming convention (TEST_, SHOULD_) in AUnit.

> **ATC Finding Message:** `Test methods should start with TEST_ or SHOULD_`

## 🧠 Rationale & Best Practices

Test method names should clearly state the condition and expected outcome (e.g., `calculate_discount_when_gold`). Meaningful test names act as living documentation.

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

## 🛠️ CLI / CI Configuration (`skylint.yaml`)

```yaml
checks:
  test-method-naming:
    enabled: true
    severity: warning
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

## 🔍 ABAP Implementation Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_TEST_NAME`
* **Finding Code:** `TEST_NAME`
* **Implementation File:** [zcl_skylint_pref_test_name.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_test_name.clas.abap)
