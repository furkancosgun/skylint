---
title: "Raise Class-Based Exceptions Instead of Obsolete MESSAGE ... RAISING"
description: "Eliminate obsolete MESSAGE RAISING statements and adopt class-based exceptions in ABAP Cloud and SAP S/4HANA systems."
keywords: "no-msg-raising, Clean ABAP, ABAP Cloud, class-based exceptions, RAISE EXCEPTION, SAP ATC"
category: "anti-patterns"
ruleId: "no-msg-raising"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2364"
---

# Raise Class-Based Exceptions Instead of Obsolete MESSAGE ... RAISING

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_MSG_RAISING" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2364" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid MESSAGE ... RAISING; use class-based exceptions.

> **ATC Finding Message:** `Avoid obsolete MESSAGE ... RAISING; raise class-based exceptions`

## Rationale

The MESSAGE ... RAISING statement mixes presentation-tier message output with procedural exception propagation and relies on classic non-class-based exception tables and sy-subrc checks. Modern Clean ABAP and ABAP Cloud Contract C1 mandate class-based exceptions (inheriting from CX_STATIC_CHECK or CX_NO_CHECK) using RAISE EXCEPTION NEW or RAISE EXCEPTION TYPE, optionally carrying T100 message keys via IF_T100_MESSAGE or IF_T100_DYN_MSG. The ATC check reports NO_MSG_RSG for any MESSAGE statement specifying RAISING.

### Non-Compliant

```abap
MESSAGE e002(zorder) WITH lv_order_id RAISING order_not_found.
```

### Compliant

```abap
RAISE EXCEPTION NEW cx_order_processing_failed(
  textid = cx_order_processing_failed=>order_not_found ).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_MSG_RAISING

" SAP CI_ prefix format:
... "#EC CI_NO_MSG_RAISING
```

## Detection Details

The check scans statements outside class definitions for the keyword `MESSAGE` combined with the keyword token `RAISING`. In ABAP Cloud, classic exceptions are obsolete and incompatible with modern exception handling semantics.

### Recommended Migration
Define custom exception classes implementing `IF_T100_MESSAGE` or `IF_T100_DYN_MSG` and instantiate them with `RAISE EXCEPTION NEW cx_my_error( ... )`.

### Suppression
Suppress findings with the pseudo comment `"#EC NO_MSG_RAISING`.


## Related Rules

* [Use Centralized Message Classes Instead of Hardcoded Text Literals](/rules/pref-msg-cls) — <code>#EC PREF_MSG_CLS</code>
* [Replace Obsolete String Statements and POSIX Regular Expressions](/rules/no-obs-strings) — <code>#EC NO_OBS_STRINGS</code>
* [Fold Adjacent Static String Literals Concatenated with &&](/rules/no-useless-concat) — <code>#EC NO_USELESS_CONCAT</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_MSG_RAISING`
* **ABAP Implementation:** [/skyl/cl_no_msg_raising.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_msg_raising.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 2364)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L2364)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_MSG_RAISING&title=%5BBug%5D%3A%20Issue%20in%20no-msg-raising)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-msg-raising)**
