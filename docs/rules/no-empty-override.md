---
title: "Avoid Method Override That Only Delegates to Super"
description: "Avoid Method Override That Only Delegates to Super - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-empty-override, anti-patterns"
category: "anti-patterns"
ruleId: "no-empty-override"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3891"
---

# Avoid Method Override That Only Delegates to Super

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_EMPTY_OVERRIDE" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3891" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid method override that only calls super.

> **ATC Finding Message:** `Empty method override; method only delegates to super`

## Rationale

Redefining a method only to immediately call the superclass method without performing any additional initialization, logging, argument transformation, or side effect is redundant. It clutters the method implementation, adds needless call stack overhead, and requires maintenance whenever super signatures change. Omit the empty override and let polymorphism delegate to the superclass naturally.

### Non-Compliant

```abap
METHOD do_work.
  super->do_work( ).
ENDMETHOD.
```

### Compliant

```abap
" Omit method redefinition and let superclass handle execution naturally
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `IGNORE_CTOR` | `Boolean` | <code>true</code> | Ignore empty constructor redefinitions (when only calling super->constructor) |
| `IGNORE_CHECK` | `Boolean` | <code>true</code> | Ignore empty redefinitions in test classes or abstract interfaces |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_EMPTY_OVERRIDE

" SAP CI_ prefix format:
... "#EC CI_NO_EMPTY_OVERRIDE
```


## Related Rules

* [Avoid FRIENDS in class definitions](/rules/no-friends) — <code>#EC NO_FRIENDS</code>
* [Avoid Purely Static Utility Classes](/rules/no-static-cls) — <code>#EC NO_STATIC_CLS</code>
* [Avoid Calling Static Methods via Instance References (->)](/rules/no-static-arrow) — <code>#EC NO_STATIC_ARROW</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_EMPTY_OVERRIDE`
* **ABAP Implementation:** [/skyl/cl_no_empty_override.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_empty_override.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3891)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3891)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_EMPTY_OVERRIDE&title=%5BBug%5D%3A%20Issue%20in%20no-empty-override)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-empty-override)**
