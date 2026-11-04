---
title: "Avoid Dynamic MESSAGE Statements"
description: "Avoid dynamic MESSAGE ID TYPE NUMBER statements in ABAP - keep message identifiers static for easy SE91 where-used search. Clean ABAP message handling and automated ATC inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Dynamic MESSAGE ABAP, Message Class Usage, SE91 Where Used, Clean ABAP Messages, ATC Code Review"
category: "clean-abap"
ruleId: "no-dyn-message"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5286"
---

# Avoid Dynamic MESSAGE Statements

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC NO_DYN_MESSAGE" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5286" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid Dynamic MESSAGE Statements.

> **ATC Finding Message:** `MESSAGE works with a dynamic operand - keep ID, TYPE and NUMBER static`

## Rationale

`MESSAGE ... ID <dyn> TYPE <dyn> NUMBER <dyn>` hides the message source: it cannot be found through a where-used search from SE91, defeats static analysis of message usage, and makes text and behavior depend on runtime values. Keep ID, TYPE and NUMBER static so the message is easy to find along the Clean ABAP Make messages easy to find guidance; inline-text MESSAGE forms are covered by pref-msg-cls.

### Non-Compliant

```abap
MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
  WITH sy-msgv1 sy-msgv2 INTO lv_text.
```

### Compliant

```abap
MESSAGE e001(msg_class)
  WITH sy-msgv1 sy-msgv2 INTO lv_text.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_DYN_MESSAGE

" SAP CI_ prefix format:
... "#EC CI_NO_DYN_MESSAGE
```


## Related Rules

* [Use a message class (SE91) instead of inline message text](/rules/pref-msg-cls) — <code>#EC PREF_MSG_CLS</code>
* [Avoid Obsolete MESSAGE ... RAISING in Methods](/rules/no-msg-raising) — <code>#EC NO_MSG_RAISING</code>
* [Avoid Unnecessary Dynamic Programming Constructs (SQL Injection Prevention)](/rules/no-dynamic-stmt) — <code>#EC NO_DYNAMIC_STMT</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_DYN_MESSAGE`
* **ABAP Implementation:** [/skyl/cl_no_dyn_message.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_dyn_message.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 5286)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L5286)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_DYN_MESSAGE&title=%5BBug%5D%3A%20Issue%20in%20no-dyn-message)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-dyn-message)**
