---
title: "Avoid IS INSTANCE OF and CASE TYPE OF Type Tests"
description: "Avoid IS INSTANCE OF and CASE TYPE OF Type Tests - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-instance-of, clean-abap"
category: "clean-abap"
ruleId: "no-instance-of"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4109"
---

# Avoid IS INSTANCE OF and CASE TYPE OF Type Tests

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC NO_INSTANCE_OF" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4109" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid IS INSTANCE OF / CASE TYPE OF checks.

> **ATC Finding Message:** `Avoid runtime type checks via IS INSTANCE OF; use polymorphism`

## Rationale

Checking concrete object types at runtime via IS INSTANCE OF or CASE TYPE OF breaks polymorphism, violates the Open-Closed Principle, and introduces fragile type coupling. Instead of conditional type inspection, introduce polymorphic methods on common interfaces.

### Non-Compliant

```abap
IF io_shape IS INSTANCE OF cl_circle.
  render_circle( ).
ENDIF.
```

### Compliant

```abap
io_shape->render( ).
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_CASE_TYPE` | `Boolean` | <code>true</code> | Report CASE TYPE OF type tests in addition to IS INSTANCE OF |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_INSTANCE_OF

" SAP CI_ prefix format:
... "#EC CI_NO_INSTANCE_OF
```


## Related Rules

* [Avoid Calling Static Methods via Instance References (->)](/rules/no-static-arrow) — <code>#EC NO_STATIC_ARROW</code>
* [Avoid Exposed Mutable Data in Classes and Interfaces](/rules/no-exposed-data) — <code>#EC PUBLIC_ATTR</code>
* [Prefer NEW #( ) over CREATE OBJECT](/rules/pref-new-op) — <code>#EC PREF_NEW_OPERATOR</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_INSTANCE_OF`
* **ABAP Implementation:** [/skyl/cl_no_instance_of.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_instance_of.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4109)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4109)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_INSTANCE_OF&title=%5BBug%5D%3A%20Issue%20in%20no-instance-of)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-instance-of)**
