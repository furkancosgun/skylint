---
title: "Avoid Using ABAP Keywords as Identifier Names"
description: "Avoid Using ABAP Keywords as Identifier Names - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-keyword-name, anti-patterns"
category: "anti-patterns"
ruleId: "no-keyword-name"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3552"
---

# Avoid Using ABAP Keywords as Identifier Names

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_KEYWORD_NAME" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3552" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid Using ABAP Keywords as Identifier Names.

> **ATC Finding Message:** `Identifier name matches an ABAP keyword`

## Rationale

Using a language keyword such as class, type, or data as an identifier shadows the keyword and forces readers to disambiguate from context. It also complicates searching and can confuse tooling. Prefix identifiers with their role, for example lv_type.

### Non-Compliant

```abap
DATA interface TYPE string.
DATA report TYPE i.
```

### Compliant

```abap
DATA lv_interface TYPE string.
DATA lv_report TYPE i.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_KEYWORD_NAME

" SAP CI_ prefix format:
... "#EC CI_NO_KEYWORD_NAME
```


## Related Rules

* [Enforce Class Attribute and Method Parameter Naming Conventions](/rules/pref-name-members) — <code>#EC PREF_NAME_MEMBERS</code>
* [Enforce Class, Interface, Type and Object Naming Conventions](/rules/pref-name-objects) — <code>#EC PREF_NAME_OBJECTS</code>
* [Use Predicate Naming for Boolean Methods (is_, has_, can_)](/rules/pref-pred-name) — <code>#EC PREF_PRED_NAME</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_KEYWORD_NAME`
* **ABAP Implementation:** [/skyl/cl_no_keyword_name.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_keyword_name.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3552)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3552)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_KEYWORD_NAME&title=%5BBug%5D%3A%20Issue%20in%20no-keyword-name)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-keyword-name)**
