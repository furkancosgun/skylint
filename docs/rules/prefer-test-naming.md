# Follow Clean Naming for Unit Test Methods

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="Finding: TEST_NAME" />
</div>

## Overview

Enforce test method naming (TEST_, SHOULD_) in AUnit.

> **ATC Finding Message:** `Test methods should start with TEST_ or SHOULD_`

## Rationale

Test method names should clearly state the condition and expected outcome (e.g., `calculate_discount_when_gold`). Meaningful test names act as living documentation.

### Non-Compliant

```abap
METHODS calculate_discount FOR TESTING.
```

### Compliant

```abap
METHODS test_calculate_discount FOR TESTING.
" Or:
METHODS should_calculate_discount FOR TESTING.
```

## Transformation

```diff
- METHODS calculate_discount FOR TESTING.
+ METHODS test_calculate_discount FOR TESTING.
+ " Or:
+ METHODS should_calculate_discount FOR TESTING.
```

## CLI & CI/CD Configuration

```yaml
checks:
  prefer-test-naming:
    enabled: true
    severity: warning
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC TEST_NAME

" SAP CI_ prefix format:
... "#EC CI_TEST_NAME
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_TEST_NAME`
* **Finding Code:** `TEST_NAME`
* **Implementation File:** [zcl_skylint_pref_test_name.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_test_name.clas.abap)
