---
title: "Avoid Protected Attributes"
description: "Enforce clean encapsulation by disallowing DATA in class PROTECTED SECTION."
keywords: "Clean ABAP, protected data, no-protected-data"
category: "clean-abap"
ruleId: "no-protected-data"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4849"
---

# Avoid Protected Attributes

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC NO_PROTECTED_DATA" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4849" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid declaring DATA or CLASS-DATA in PROTECTED SECTION.

> **ATC Finding Message:** `Avoid protected attributes; make them private and provide methods instead`

## Rationale

Protected data members expose internal class state to subclasses, violating encapsulation. Make attributes private and provide getter methods if needed.

### Non-Compliant

```abap
PROTECTED SECTION.
  DATA mv_count TYPE i.
```

### Compliant

```abap
PRIVATE SECTION.
  DATA mv_count TYPE i.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_PROTECTED_DATA

" SAP CI_ prefix format:
... "#EC CI_NO_PROTECTED_DATA
```


## Related Rules

* [Avoid Exposed Mutable Data in Classes and Interfaces](/rules/no-exposed-data) — <code>#EC PUBLIC_ATTR</code>
* [Limit Class Member Attribute Count (Prevent God Classes)](/rules/max-attributes) — <code>#EC MAX_ATTRIBUTES</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_PROTECTED_DATA`
* **ABAP Implementation:** [/skyl/cl_no_protected_data.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_protected_data.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4849)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4849)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_PROTECTED_DATA&title=%5BBug%5D%3A%20Issue%20in%20no-protected-data)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-protected-data)**
