---
title: "Declare DURATION and RISK LEVEL on ABAP Unit Test Classes"
description: "Require DURATION SHORT and RISK LEVEL HARMLESS on ABAP Unit FOR TESTING classes - stable test runner behaviour and CI-ready unit tests."
keywords: "ABAP Unit DURATION, RISK LEVEL HARMLESS, FOR TESTING class, pref-test-attributes, ABAP Cloud"
category: "clean-abap"
ruleId: "pref-test-attributes"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5204"
---

# Declare DURATION and RISK LEVEL on ABAP Unit Test Classes

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_TEST_ATTR" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5204" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Require DURATION and RISK LEVEL attributes on test classes.

> **ATC Finding Message:** `Test class must declare DURATION and RISK LEVEL attributes`

## Rationale

DURATION and RISK LEVEL tell the ABAP Unit runner how a test class behaves: SHORT tests are pure in-memory checks, MEDIUM tests may touch the database, LONG tests may run for minutes, while RISK LEVEL HARMLESS promises no changes to persistent data. Without explicit attributes the runner must assume the worst case, so a hermetic unit test can be skipped in restricted systems, blocked by the commit/rollback guard or moved to a slow nightly job instead of running in CI on every transport. The check validates every CLASS ... DEFINITION FOR TESTING statement and reports PREF_TSTAT when DURATION or RISK LEVEL is missing, while CHECK_DURATION and CHECK_RISK_LEVEL let teams adopt the two attributes gradually. Explicit attributes also document intent to reviewers and keep test execution time predictable.

### Non-Compliant

```abap
CLASS lcl_order_service_test DEFINITION FOR TESTING.
  PUBLIC SECTION.
    METHODS test_total_is_rounded.
ENDCLASS.
```

### Compliant

```abap
CLASS lcl_order_service_test DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PUBLIC SECTION.
    METHODS test_total_is_rounded.
ENDCLASS.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_DURATION` | `Boolean` | <code>true</code> | Report test classes that do not declare DURATION (SHORT, MEDIUM or LONG). Keep true to require runtime classification; set false only while migrating legacy test includes. |
| `CHECK_RISK_LEVEL` | `Boolean` | <code>true</code> | Report test classes that do not declare RISK LEVEL (HARMLESS, DANGEROUS or CRITICAL). Keep true so tests with database commits are clearly marked; set false for teams that only track runtime. |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_TEST_ATTR

" SAP CI_ prefix format:
... "#EC CI_PREF_TEST_ATTR
```

## Attributes

| Attribute | Allowed values | Meaning |
| --- | --- | --- |
| `DURATION` | `SHORT`, `MEDIUM`, `LONG` | expected runtime class of the test |
| `RISK LEVEL` | `HARMLESS`, `DANGEROUS`, `CRITICAL` | side effects on persistent data |

Recommended default for hermetic unit tests: `DURATION SHORT RISK LEVEL HARMLESS`.

## Parameters

| Parameter | Default | Effect |
| --- | --- | --- |
| `CHECK_DURATION` | `true` | report a missing `DURATION` |
| `CHECK_RISK_LEVEL` | `true` | report a missing `RISK LEVEL` |

## Notes

- Only classes with `FOR TESTING` are inspected; production classes and plain helper classes are ignored.
- A test class with only `DURATION` is still reported (once) because `RISK LEVEL` is missing, and vice versa.
- Suppress per class with `"#EC PREF_TEST_ATTR` on the `CLASS ... DEFINITION` line.
- `RISK LEVEL` is written as two tokens (`RISK` `LEVEL`); both must appear on the `CLASS` statement, not on a separate line of the definition.


## Related Rules

* [Avoid Native ASSERT Statements in Production Logic](/rules/no-prod-assert) — <code>#EC NO_PROD_ASSERT</code>
* [Design for Inheritance or Prohibit It with FINAL](/rules/pref-final-cls) — <code>#EC PREF_FINAL_CLASS</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_TEST_ATTR`
* **ABAP Implementation:** [/skyl/cl_pref_test_attr.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_test_attr.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 5204)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L5204)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_TEST_ATTR&title=%5BBug%5D%3A%20Issue%20in%20pref-test-attributes)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-test-attributes)**
