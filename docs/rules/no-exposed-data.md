---
title: "Encapsulate Public Class Attributes and Interface Variables"
description: "Enforce encapsulation by prohibiting mutable public class attributes and interface DATA in ABAP Cloud."
keywords: "no-exposed-data, encapsulation, READ-ONLY, interface data, Clean ABAP"
category: "anti-patterns"
ruleId: "no-exposed-data"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1120"
---

# Encapsulate Public Class Attributes and Interface Variables

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

Exposing mutable DATA attributes in class PUBLIC sections or declaring DATA inside interfaces breaches core object-oriented encapsulation by allowing external consumers to directly mutate internal state without validation or invariant enforcement. In ABAP Cloud and Clean ABAP architecture, classes must protect internal representation using PRIVATE or PROTECTED sections accompanied by dedicated accessor methods or READ-ONLY declarations. Interfaces must represent pure contracts containing only method definitions, types, and immutable CONSTANTS.

### Non-Compliant

```abap
CLASS zcl_customer_profile DEFINITION PUBLIC CREATE PUBLIC.
  PUBLIC SECTION.
    DATA mv_credit_limit TYPE p LENGTH 8 DECIMALS 2.
ENDCLASS.
```

### Compliant

```abap
CLASS zcl_customer_profile DEFINITION PUBLIC CREATE PUBLIC.
  PUBLIC SECTION.
    DATA mv_credit_limit TYPE p LENGTH 8 DECIMALS 2 READ-ONLY.
ENDCLASS.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_PUBLIC_ATTR` | `Boolean` | <code>true</code> | Report public class attributes that lack the READ-ONLY addition to prevent unrestricted mutation. |
| `CHECK_INTF_DATA` | `Boolean` | <code>true</code> | Report mutable DATA and CLASS-DATA variable declarations inside interfaces; use methods or CONSTANTS. |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PUBLIC_ATTR

" SAP CI_ prefix format:
... "#EC CI_PUBLIC_ATTR
```

### Finding Codes and Configuration

| Finding Code | Description | Pseudo-Comment |
|---|---|---|
| `NO_PUB_ATR` | Mutable `DATA` or `CLASS-DATA` attribute declared in `PUBLIC SECTION` without `READ-ONLY` | `"#EC NO_PUBLIC_ATTR` |
| `NO_INTF_DA` | Mutable `DATA` or `CLASS-DATA` declaration located inside an `INTERFACE` | `"#EC NO_INTERFACE_DATA` |

Both checks are enabled by default and can be configured independently through rule parameters.


## Related Rules

* [Design Classes with Instance Methods and Interfaces Instead of Static-Only Utilities](/rules/no-static-cls) — <code>#EC NO_STATIC_CLS</code>
* [Prefer Small, Role-Based Interfaces (Interface Segregation)](/rules/pref-intf-segreg) — <code>#EC PREF_INTF_SEGREG</code>
* [Replace IS INSTANCE OF and CASE TYPE OF with Polymorphism](/rules/no-instance-of) — <code>#EC NO_INSTANCE_OF</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_EXPOSED_DATA`
* **ABAP Implementation:** [/skyl/cl_no_exposed_data.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_exposed_data.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 1120)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L1120)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_EXPOSED_DATA&title=%5BBug%5D%3A%20Issue%20in%20no-exposed-data)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-exposed-data)**
