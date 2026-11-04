---
title: "Modernize Downcasting (CAST #( ) Expression & Inlining)"
description: "Modernize Downcasting (CAST #( ) Expression & Inlining) - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-downcast, clean-abap"
category: "clean-abap"
ruleId: "pref-downcast"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3237"
---

# Modernize Downcasting (CAST #( ) Expression & Inlining)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_CAST" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3237" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Modernize Downcasting (CAST #( ) & inlining).

> **ATC Finding Messages:**
> - `Prefer CAST #( ) constructor expression over ?= downcast`
> - `CAST helper is read exactly once in the next statement; inline it`

## Rationale

The legacy ?= and MOVE ?TO operators are obsolete downcast statements that cannot be chained or used in modern expressions. The modern CAST #( ) expression creates cleanly typed references that can be used directly in chained calls or assignments. Furthermore, single-use downcast helper variables should be inlined into the consuming expression to prevent clutter and unnecessary temporary state.

### Non-Compliant

```abap
lo_child ?= lo_parent.
DATA(lo_node) = CAST lcl_node( io_obj ).
result = lo_node->get_tokens( ).
```

### Compliant

```abap
lo_child = CAST #( lo_parent ).
result = CAST lcl_node( io_obj )->get_tokens( ).
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
| `CHECK_CAST_SYNTAX` | `Boolean` | <code>true</code> | Suggest modern ?= over obsolete downcast syntax |
| `CHECK_INLINE_CAST` | `Boolean` | <code>true</code> | Suggest CAST #( ... ) constructor expression over intermediate temporary reference |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_CAST

" SAP CI_ prefix format:
... "#EC CI_PREF_CAST
```


## Related Rules

* [Prefer NEW #( ) over CREATE OBJECT](/rules/pref-new-op) — <code>#EC PREF_NEW_OPERATOR</code>
* [Declare Constructor in PUBLIC SECTION](/rules/pref-pub-ctor) — <code>#EC PREF_PUB_CTOR</code>
* [Prefer CREATE_* Prefix for Factory Methods Returning Own Class](/rules/pref-factory-name) — <code>#EC PREF_FACTORY_NAME</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_DOWNCAST`
* **ABAP Implementation:** [/skyl/cl_pref_downcast.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_downcast.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3237)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3237)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_DOWNCAST&title=%5BBug%5D%3A%20Issue%20in%20pref-downcast)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-downcast)**
