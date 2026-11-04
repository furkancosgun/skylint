---
title: "Avoid Abstract Final Classes"
description: "Detect classes declared with conflicting ABSTRACT and FINAL modifiers."
keywords: "Clean ABAP, abstract final, no-abstract-final"
category: "anti-patterns"
ruleId: "no-abstract-final"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4703"
---

# Avoid Abstract Final Classes

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_ABSTRACT_FINAL" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4703" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

A class cannot be defined as both ABSTRACT and FINAL.

> **ATC Finding Message:** `Class cannot be both ABSTRACT and FINAL`

## Rationale

A class cannot be both ABSTRACT and FINAL simultaneously. Abstract classes must be inherited from, while final classes prohibit inheritance.

### Non-Compliant

```abap
CLASS lcl_demo DEFINITION ABSTRACT FINAL.
ENDCLASS.
```

### Compliant

```abap
CLASS lcl_demo DEFINITION FINAL.
ENDCLASS.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_ABSTRACT_FINAL

" SAP CI_ prefix format:
... "#EC CI_NO_ABSTRACT_FINAL
```


## Related Rules

* [Avoid Empty Procedures](/rules/no-empty-proc) — <code>#EC NO_EMPTY_PROC</code>
* [Avoid Dead Code with Constant Conditions](/rules/no-dead-code) — <code>#EC NO_DEAD_CODE</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_ABSTRACT_FINAL`
* **ABAP Implementation:** [/skyl/cl_no_abstract_final.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_abstract_final.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4703)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4703)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_ABSTRACT_FINAL&title=%5BBug%5D%3A%20Issue%20in%20no-abstract-final)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-abstract-final)**
