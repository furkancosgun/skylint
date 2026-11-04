---
title: "Require Explicit DURATION and RISK LEVEL Attributes on Test Classes"
description: "Enforce explicit DURATION and RISK LEVEL declarations on ABAP Unit test classes. Standardize ABAP testing best practices and CI/CD test runner stability."
keywords: "ABAP Unit FOR TESTING, DURATION SHORT ABAP, RISK LEVEL HARMLESS, Clean ABAP Testing Guidelines"
category: "clean-abap"
ruleId: "pref-test-attributes"
---

# Require Explicit DURATION and RISK LEVEL Attributes on Test Classes

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_TEST_ATTR" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Require DURATION and RISK LEVEL attributes on test classes.

> **ATC Finding Message:** `Test class must declare DURATION and RISK LEVEL attributes`

## Rationale

ABAP Unit test classes (`FOR TESTING`) should declare explicit `DURATION` (SHORT, MEDIUM, or LONG) and `RISK LEVEL` (HARMLESS, DANGEROUS, or CRITICAL) attributes on their `CLASS ... DEFINITION` statement. Without explicit attributes, the test runner assigns default values that may cause tests with external dependencies or database commits to execute in restricted test environments or time out prematurely.

**Best Practice:** Always declare `DURATION SHORT RISK LEVEL HARMLESS` for fast, hermetic unit tests.

### Non-Compliant

```abap
" Anti-pattern: Test class without duration or risk level attributes
CLASS lcl_order_test DEFINITION FOR TESTING.
  PUBLIC SECTION.
    METHODS test_calculation FOR TESTING.
ENDCLASS.
```

### Compliant

```abap
" Clean ABAP: Explicit duration and risk level declaration
CLASS lcl_order_test DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PUBLIC SECTION.
    METHODS test_calculation FOR TESTING.
ENDCLASS.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_DURATION` | `Boolean` | <code>true</code> | Require explicit DURATION attribute (SHORT, MEDIUM, LONG) |
| `CHECK_RISK_LEVEL` | `Boolean` | <code>true</code> | Require explicit RISK LEVEL attribute (HARMLESS, DANGEROUS, CRITICAL) |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_TEST_ATTR

" SAP CI_ prefix format:
... "#EC CI_PREF_TEST_ATTR
```


## Related Rules

* [Avoid Native ASSERT in Production Code (Prevent Unrecoverable Dumps)](/rules/no-prod-assert) — <code>#EC NO_PROD_ASSERT</code>
* [Design for Inheritance or Prohibit It (FINAL)](/rules/pref-final-cls) — <code>#EC PREF_FINAL_CLASS</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_TEST_ATTR`
* **Implementation File:** [#skyl#cl_pref_test_attr.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_test_attr.clas.abap)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_TEST_ATTR&title=%5BBug%5D%3A%20Issue%20in%20pref-test-attributes)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-test-attributes)**
