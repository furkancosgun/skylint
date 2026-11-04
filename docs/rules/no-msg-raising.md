---
title: "Avoid Obsolete MESSAGE ... RAISING in Methods"
description: "Avoid Obsolete MESSAGE ... RAISING in Methods - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-msg-raising, anti-patterns"
category: "anti-patterns"
ruleId: "no-msg-raising"
---

# Avoid Obsolete MESSAGE ... RAISING in Methods

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_MSG_RAISING" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid MESSAGE ... RAISING; use class-based exceptions.

> **ATC Finding Message:** `Avoid obsolete MESSAGE ... RAISING; raise class-based exceptions`

## Rationale

MESSAGE ... RAISING mixes UI message output with exception propagation and depends on classic exception numbers. It separates poorly from business logic and is unsuitable for APIs that should return typed failures. Raise a class-based exception that references the message class text instead.

### Non-Compliant

```abap
MESSAGE e002(zorder) RAISING not_found.
```

### Compliant

```abap
RAISE EXCEPTION NEW cx_order_not_found( textid = cx_order_not_found=>c_order_missing ).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_MSG_RAISING

" SAP CI_ prefix format:
... "#EC CI_NO_MSG_RAISING
```


## Related Rules

* [Use a message class (SE91) instead of inline message text](/rules/pref-msg-cls) — <code>#EC PREF_MSG_CLS</code>
* [Avoid Obsolete String and POSIX Regex Statements](/rules/no-obs-strings) — <code>#EC NO_OBS_STRINGS</code>
* [Avoid Concatenating Adjacent String Literals](/rules/no-useless-concat) — <code>#EC NO_USELESS_CONCAT</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_MSG_RAISING`
* **Implementation File:** [#skyl#cl_no_msg_raising.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_msg_raising.clas.abap)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_MSG_RAISING&title=%5BBug%5D%3A%20Issue%20in%20no-msg-raising)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-msg-raising)**
