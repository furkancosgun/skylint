---
title: "Avoid Redundant ME-> Self-References to Instance Members"
description: "Remove redundant ME-> self-references from instance method calls and attribute accesses in Clean ABAP."
keywords: "no-me-reference, ME self-reference, Clean ABAP, ABAP Objects, SAP ATC"
category: "anti-patterns"
ruleId: "no-me-reference"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L472"
---

# Avoid Redundant ME-> Self-References to Instance Members

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

In ABAP Objects, instance methods and member attributes are directly visible within instance methods without requiring the me-> prefix. Adding me-> to everyday variable access or helper method calls introduces visual noise, distracts reviewers, and runs counter to Clean ABAP style guidelines. The self-reference should be reserved for disambiguating shadowed member attributes inside constructors or setters. The check flags redundant me-> tokens with NO_ME_REF and provides the OMITME quickfix.

### Non-Compliant

```abap
me->mv_total_amount = me->mv_total_amount + lv_item_amount.
me->persist_invoice( ).
```

### Compliant

```abap
mv_total_amount = mv_total_amount + lv_item_amount.
persist_invoice( ).
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
| `ALLOW_IN_CONSTRUCTORS` | `Boolean` | <code>true</code> | Allow me-> self-references within CONSTRUCTOR methods to resolve shadowed parameter names. |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_ME_REFERENCE

" SAP CI_ prefix format:
... "#EC CI_NO_ME_REFERENCE
```

### Disambiguation and QuickFix

Clean ABAP advises omitting `me->` unless an imported parameter or local variable shares the exact name of a member attribute:

- In normal methods, `me->do_something( )` and `me->mv_status` are reported.
- When `ALLOW_IN_CONSTRUCTORS` is set to `abap_true` (default), constructor methods (`*=>CONSTRUCTOR`) are exempt to facilitate parameter assignments such as `me->mv_id = iv_id`.

The `OMITME` quickfix strips `me->` from the statement automatically. Suppress findings using `"#EC NO_ME_REFERENCE`.


## Related Rules

* [Replace Obsolete CALL METHOD Statements with Functional Invocations](/rules/no-call-method) — <code>#EC NO_CALL_METHOD</code>
* [Enforce Standard Naming Conventions for Class Members, Parameters and Screens](/rules/pref-name-members) — <code>#EC PREF_NAME_MEMBERS</code>
* [Call Static Methods with Class Component Selector (=>)](/rules/no-static-arrow) — <code>#EC NO_STATIC_ARROW</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_ME_REFERENCE`
* **ABAP Implementation:** [/skyl/cl_no_me_reference.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_me_reference.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 472)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L472)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_ME_REFERENCE&title=%5BBug%5D%3A%20Issue%20in%20no-me-reference)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-me-reference)**
