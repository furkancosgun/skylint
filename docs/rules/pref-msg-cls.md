---
title: "Use Centralized Message Classes Instead of Hardcoded Text Literals"
description: "Replace hardcoded string literals in ABAP MESSAGE statements with SE91 message classes to ensure internationalization and SAP S/4HANA readiness."
keywords: "pref-msg-cls, MESSAGE, SE91, message class, Clean ABAP, ABAP Cloud"
category: "clean-abap"
ruleId: "pref-msg-cls"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2899"
---

# Use Centralized Message Classes Instead of Hardcoded Text Literals

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_MSG_CLS" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2899" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Use a message class instead of inline message text.

> **ATC Finding Message:** `Define the message class and raise it as e001( msg_class )`

## Rationale

Hardcoded message literals cannot be translated via transaction SE91, cannot be cataloged across business components, and violate internationalization requirements in SAP S/4HANA and ABAP Cloud. Centralizing message definitions within message classes ensures structured error codes, parameterized placeholders, and proper multilingual maintenance. Skylint inspects MESSAGE statements and reports PREF_MSGCL when inline string literals are used instead of structured message class references.

### Non-Compliant

```abap
MESSAGE 'Customer account is locked for posting' TYPE 'E' INTO DATA(lv_error_text).
```

### Compliant

```abap
MESSAGE e102(zsales_msg) INTO DATA(lv_error_text).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_MSG_CLS

" SAP CI_ prefix format:
... "#EC CI_PREF_MSG_CLS
```

## Detection Details

The check evaluates statements starting with keyword `MESSAGE`. Statements providing an explicit message class via `ID <class>` or standard short-syntax `t<nnn>(<class>)` are accepted. If the token directly following `MESSAGE` is a string literal (e.g., `MESSAGE '...' TYPE 'E'`), ATC finding `PREF_MSGCL` is raised.

Suppress findings using pseudo comment `"#EC PREF_MSG_CLS`.


## Related Rules

* [Raise Class-Based Exceptions Instead of Obsolete MESSAGE ... RAISING](/rules/no-msg-raising) — <code>#EC NO_MSG_RAISING</code>
* [Compose Messages with String Templates Instead of CONCATENATE](/rules/pref-str-tmpl) — <code>#EC PREF_STR_TMPL</code>
* [Replace Obsolete String Statements with Built-in String Functions](/rules/pref-str-func) — <code>#EC PREF_STR_FUNC</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_MSG_CLS`
* **ABAP Implementation:** [/skyl/cl_pref_msg_cls.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_msg_cls.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 2899)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L2899)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_MSG_CLS&title=%5BBug%5D%3A%20Issue%20in%20pref-msg-cls)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-msg-cls)**
