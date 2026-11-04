---
title: "Avoid Exposed Mutable Data in Classes and Interfaces"
description: "Avoid Exposed Mutable Data in Classes and Interfaces - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-exposed-data, anti-patterns"
category: "anti-patterns"
ruleId: "no-exposed-data"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1120"
---

# Avoid Exposed Mutable Data in Classes and Interfaces

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC PUBLIC_ATTR" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1120" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid mutable data in public classes and interfaces.

> **ATC Finding Messages:**
> - `Avoid public attributes; use private/protected with getters or READ-ONLY`
> - `Avoid mutable DATA in interfaces; declare CONSTANTS or move to class`

## Rationale

Public mutable attributes in classes and DATA declarations in interfaces breach object-oriented encapsulation by allowing external callers to directly mutate internal state without invariant validation. Exposing state leaks implementation details and prevents clean contract evolution. Restrict data to PRIVATE/PROTECTED sections with getters (or READ-ONLY), and keep interfaces strictly stateless with methods and CONSTANTS.

### Non-Compliant

```abap
CLASS cl_model DEFINITION PUBLIC.
  PUBLIC SECTION.
    DATA mv_state TYPE i.
ENDCLASS.
INTERFACE if_customer.
  DATA mv_balance TYPE i.
ENDINTERFACE.
```

### Compliant

```abap
CLASS cl_model DEFINITION PUBLIC.
  PUBLIC SECTION.
    DATA mv_state TYPE i READ-ONLY.
ENDCLASS.
INTERFACE if_customer.
  CONSTANTS c_default_status TYPE i VALUE 1.
  METHODS get_balance RETURNING VALUE(rv_balance) TYPE i.
ENDINTERFACE.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_PUBLIC_ATTR` | `Boolean` | <code>true</code> | Report public data attributes in classes (encapsulation violation) |
| `CHECK_INTF_DATA` | `Boolean` | <code>true</code> | Report data variable declarations inside interfaces (should contain only types, constants, methods) |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PUBLIC_ATTR

" SAP CI_ prefix format:
... "#EC CI_PUBLIC_ATTR
```


## Related Rules

* [Avoid Purely Static Utility Classes](/rules/no-static-cls) — <code>#EC NO_STATIC_CLS</code>
* [Prefer Interface Segregation (Small, Focused Interfaces)](/rules/pref-intf-segreg) — <code>#EC PREF_INTF_SEGREG</code>
* [Avoid IS INSTANCE OF and CASE TYPE OF Type Tests](/rules/no-instance-of) — <code>#EC NO_INSTANCE_OF</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_EXPOSED_DATA`
* **ABAP Implementation:** [/skyl/cl_no_exposed_data.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_exposed_data.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 1120)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L1120)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_EXPOSED_DATA&title=%5BBug%5D%3A%20Issue%20in%20no-exposed-data)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-exposed-data)**
