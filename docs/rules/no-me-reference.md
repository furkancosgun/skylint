---
title: "Avoid Redundant ME-> Self Reference"
description: "Avoid Redundant ME-> Self Reference - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-me-reference, anti-patterns"
category: "anti-patterns"
ruleId: "no-me-reference"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L472"
---

# Avoid Redundant ME-> Self Reference

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_ME_REFERENCE" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L472" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid self-reference ME->.

> **ATC Finding Message:** `Avoid unnecessary ME-> reference`

## Rationale

Member variables and methods are already accessible inside an instance method, so prefixing every access with me-> only adds noise. Removing the prefix keeps attention on the member itself and makes genuine shadowing easier to spot. Keep me-> only where a parameter or local variable shadows the member, typically in constructors and setters.

### Non-Compliant

```abap
me->mv_order_count = me->mv_order_count + 1.
me->save( ).
```

### Compliant

```abap
mv_order_count = mv_order_count + 1.
save( ).
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `ALLOW_IN_CONSTRUCTORS` | `Boolean` | <code>true</code> | Allow me-> in CONSTRUCTOR methods when assigning parameters with identical names to attributes |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_ME_REFERENCE

" SAP CI_ prefix format:
... "#EC CI_NO_ME_REFERENCE
```


## Related Rules

* [Avoid Obsolete CALL METHOD](/rules/no-call-method) — <code>#EC NO_CALL_METHOD</code>
* [Enforce Class Attribute and Method Parameter Naming Conventions](/rules/pref-name-members) — <code>#EC PREF_NAME_MEMBERS</code>
* [Avoid Calling Static Methods via Instance References (->)](/rules/no-static-arrow) — <code>#EC NO_STATIC_ARROW</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_ME_REFERENCE`
* **ABAP Implementation:** [/skyl/cl_no_me_reference.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_me_reference.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 472)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L472)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_ME_REFERENCE&title=%5BBug%5D%3A%20Issue%20in%20no-me-reference)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-me-reference)**
