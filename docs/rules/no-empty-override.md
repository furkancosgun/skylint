---
title: "Omit Method Redefinitions That Only Delegate to Super"
description: "Detect and remove redundant ABAP method redefinitions that merely forward execution to super without adding logic."
keywords: "method redefinition, super call ABAP, Clean ABAP inheritance, SAP ATC check, no-empty-override"
category: "anti-patterns"
ruleId: "no-empty-override"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3987"
---

# Omit Method Redefinitions That Only Delegate to Super

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_EMPTY_OVERRIDE" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3987" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid method override that only calls super.

> **ATC Finding Message:** `Empty method override; method only delegates to super`

## Rationale

Overriding a superclass method only to invoke super->method( ) without pre-processing, post-processing, logging, or error handling creates redundant boilerplate code. It inflates the call stack, complicates inheritance maintenance, and clutters class definitions. Unless behavior is being modified or extended, omit the redefinition and allow object-oriented polymorphism to dispatch to the superclass implementation directly.

### Non-Compliant

```abap
METHOD calculate_tax.
  super->calculate_tax( ).
ENDMETHOD.
```

### Compliant

```abap
METHOD calculate_tax.
  super->calculate_tax( ).
  apply_regional_surcharge( ).
ENDMETHOD.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `IGNORE_CTOR` | `Boolean` | <code>true</code> | Exclude constructor method redefinitions when they only delegate to super->constructor (default true). |
| `IGNORE_CHECK` | `Boolean` | <code>true</code> | Ignore defensive CHECK statements when determining whether a method body only delegates to super (default true). |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_EMPTY_OVERRIDE

" SAP CI_ prefix format:
... "#EC CI_NO_EMPTY_OVERRIDE
```

### Detection rules

The rule checks methods in subclasses and raises `NO_EMP_OVR` when:
1. The method body contains exactly one effective statement (ignoring `RETURN`, `EXIT`, and optionally `CHECK`).
2. That statement is a call to `SUPER-><method_name>( )`.

| Method Content | Finding raised |
| --- | --- |
| `super->do_work( ).` | yes (`NO_EMP_OVR`) |
| `super->do_work( ). RETURN.` | yes (`NO_EMP_OVR`) |
| `CHECK is_active = abap_true. super->do_work( ).` | yes with default `IGNORE_CHECK = abap_true` |
| `super->do_work( ). audit_log( ).` | no (contains active logic) |
| `super->constructor( ).` | no with default `IGNORE_CTOR = abap_true` |

### Suppression

If an empty override is strictly required by an external framework interface contract, suppress the finding with `"#EC NO_EMPTY_OVERRIDE`.


## Related Rules

* [Avoid Granting Friendship via FRIENDS in Class Definitions](/rules/no-friends) — <code>#EC NO_FRIENDS</code>
* [Design Classes with Instance Methods and Interfaces Instead of Static-Only Utilities](/rules/no-static-cls) — <code>#EC NO_STATIC_CLS</code>
* [Call Static Methods with Class Component Selector (=>)](/rules/no-static-arrow) — <code>#EC NO_STATIC_ARROW</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_EMPTY_OVERRIDE`
* **ABAP Implementation:** [/skyl/cl_no_empty_override.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_empty_override.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3987)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3987)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_EMPTY_OVERRIDE&title=%5BBug%5D%3A%20Issue%20in%20no-empty-override)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-empty-override)**
