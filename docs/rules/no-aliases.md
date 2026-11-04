---
title: "Avoid ALIASES in Classes and Interfaces"
description: "Disallow ALIASES statements to enforce explicit interface qualification."
keywords: "Clean ABAP, ALIASES, no-aliases"
category: "clean-abap"
ruleId: "no-aliases"
---

# Avoid ALIASES in Classes and Interfaces

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC NO_ALIASES" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid using ALIASES in classes and interfaces.

> **ATC Finding Message:** `Do not use ALIASES; reference interface components explicitly`

## Rationale

ALIASES obscure component origins and interface contracts. Explicitly reference interface components using the interface~member syntax.

### Non-Compliant

```abap
ALIASES run FOR lif_demo~run.
```

### Compliant

```abap
lif_demo~run( ).
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `IGNORE_PRIVATE` | `Boolean` | <code>false</code> | Ignore ALIASES in private sections (defaults to false) |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_ALIASES

" SAP CI_ prefix format:
... "#EC CI_NO_ALIASES
```


## Related Rules

* [Prefer Interface Segregation (Small, Focused Interfaces)](/rules/pref-intf-segreg) — <code>#EC PREF_INTF_SEGREG</code>
* [Avoid Concrete Class References in Interfaces](/rules/no-intf-class-ref) — <code>#EC NO_INTF_CLASS_REF</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_ALIASES`
* **Implementation File:** [#skyl#cl_no_aliases.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_aliases.clas.abap)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_ALIASES&title=%5BBug%5D%3A%20Issue%20in%20no-aliases)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-aliases)**
