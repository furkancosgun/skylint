---
title: "Use a message class (SE91) instead of inline message text"
description: "Use a message class (SE91) instead of inline message text - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-msg-cls, clean-abap"
category: "clean-abap"
ruleId: "pref-msg-cls"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2841"
---

# Use a message class (SE91) instead of inline message text

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_MSG_CLS" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2841" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Use a message class instead of inline message text.

> **ATC Finding Message:** `Define the message class and raise it as e001( msg_class )`

## Rationale

Inline message texts are not translatable through SE91 and are scattered across the codebase. A message class centralizes text, numbering, and translation for all consumers. Raise messages with MESSAGE e001(zmsg) or a class-based exception that references the message text.

### Non-Compliant

```abap
MESSAGE 'Something went wrong' TYPE 'E'.
```

### Compliant

```abap
MESSAGE e001(zmsg).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_MSG_CLS

" SAP CI_ prefix format:
... "#EC CI_PREF_MSG_CLS
```


## Related Rules

* [Avoid Obsolete MESSAGE ... RAISING in Methods](/rules/no-msg-raising) — <code>#EC NO_MSG_RAISING</code>
* [Prefer String Templates over CONCATENATE](/rules/pref-str-tmpl) — <code>#EC PREF_STR_TMPL</code>
* [Prefer Built-in String Functions over SEARCH/SHIFT](/rules/pref-str-func) — <code>#EC PREF_STR_FUNC</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_MSG_CLS`
* **ABAP Implementation:** [/skyl/cl_pref_msg_cls.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_msg_cls.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 2841)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L2841)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_MSG_CLS&title=%5BBug%5D%3A%20Issue%20in%20pref-msg-cls)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-msg-cls)**
