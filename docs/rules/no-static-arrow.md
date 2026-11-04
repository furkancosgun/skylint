---
title: "Avoid Calling Static Methods via Instance References (->)"
description: "Avoid Calling Static Methods via Instance References (->) - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-static-arrow, anti-patterns"
category: "anti-patterns"
ruleId: "no-static-arrow"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1092"
---

# Avoid Calling Static Methods via Instance References (->)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_STATIC_ARROW" />
  <Badge type="warning" text="Local Only" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1092" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid calling static methods via instance arrow (->).

> **ATC Finding Message:** `Call static method using => instead of ->`

## Rationale

Calling a static method through an instance reference uses the instance arrow and suggests polymorphic dispatch that is not happening. It also creates an unnecessary dependency on a live object. Use the class name with => so readers immediately see that the method is static and cannot be overridden.

### Non-Compliant

```abap
DATA lo_helper TYPE REF TO cl_helper.
lo_helper->format_date( lv_date ).
```

### Compliant

```abap
cl_helper=>format_date( lv_date ).
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_STATIC_ARROW

" SAP CI_ prefix format:
... "#EC CI_NO_STATIC_ARROW
```


## Related Rules

* [Avoid Purely Static Utility Classes](/rules/no-static-cls) — <code>#EC NO_STATIC_CLS</code>
* [Prefer CREATE_* Prefix for Factory Methods Returning Own Class](/rules/pref-factory-name) — <code>#EC PREF_FACTORY_NAME</code>
* [Avoid IS INSTANCE OF and CASE TYPE OF Type Tests](/rules/no-instance-of) — <code>#EC NO_INSTANCE_OF</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_STATIC_ARROW`
* **ABAP Implementation:** [/skyl/cl_no_static_arrow.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_static_arrow.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 1092)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L1092)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_STATIC_ARROW&title=%5BBug%5D%3A%20Issue%20in%20no-static-arrow)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-static-arrow)**
