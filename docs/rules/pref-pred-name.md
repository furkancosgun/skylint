---
title: "Use Predicate Naming for Boolean Methods (is_, has_, can_)"
description: "Use Predicate Naming for Boolean Methods (is_, has_, can_) - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-pred-name, clean-abap"
category: "clean-abap"
ruleId: "pref-pred-name"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2212"
---

# Use Predicate Naming for Boolean Methods (is_, has_, can_)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_PRED_NAME" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2212" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Enforce predicate naming (IS_, HAS_) on boolean methods.

> **ATC Finding Message:** `Boolean-returning method should use predicate name (IS_, HAS_, CAN_)`

## Rationale

A boolean method reads best as a yes/no question, especially when it appears inside an IF condition. Names such as check_active or get_active leave the return type ambiguous and can suggest a side effect. Use is_, has_, or can_ prefixes for methods that return abap_bool.

### Non-Compliant

```abap
METHODS check_active
  RETURNING VALUE(rv_active) TYPE abap_bool.
```

### Compliant

```abap
METHODS is_active
  RETURNING VALUE(rv_active) TYPE abap_bool.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_PRED_NAME

" SAP CI_ prefix format:
... "#EC CI_PREF_PRED_NAME
```


## Related Rules

* [Enforce Class Attribute and Method Parameter Naming Conventions](/rules/pref-name-members) — <code>#EC PREF_NAME_MEMBERS</code>
* [Enforce Class, Interface, Type and Object Naming Conventions](/rules/pref-name-objects) — <code>#EC PREF_NAME_OBJECTS</code>
* [Enforce Local Variable and Field-Symbol Naming Conventions](/rules/pref-naming-vars) — <code>#EC PREF_NAMING_VARS</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_PRED_NAME`
* **ABAP Implementation:** [/skyl/cl_pref_pred_name.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_pred_name.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 2212)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L2212)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_PRED_NAME&title=%5BBug%5D%3A%20Issue%20in%20pref-pred-name)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-pred-name)**
