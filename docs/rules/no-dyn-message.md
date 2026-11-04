---
title: "Avoid Dynamic MESSAGE Statements"
description: "Detect dynamic MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno statements in ABAP - keep message class, type and number static for SE91 where-used."
keywords: "ABAP MESSAGE statement, dynamic message ID, SE91 where-used, no-dyn-message, Clean ABAP"
category: "clean-abap"
ruleId: "no-dyn-message"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5465"
---

# Avoid Dynamic MESSAGE Statements

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC NO_DYN_MESSAGE" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5465" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid Dynamic MESSAGE Statements.

> **ATC Finding Message:** `MESSAGE works with a dynamic operand - keep ID, TYPE and NUMBER static`

## Rationale

MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno re-raises whatever the previous failed statement produced: the origin is invisible in the source, SE91 where-used cannot find the message, and the text, severity and even the meaning change with runtime values. Static message identifiers keep the message in the repository, keep ID, TYPE and NUMBER translatable and let static checks such as missing-message or unused-message analysis work. The check reports NO_DYN_MSG when the operands after ID, TYPE and NUMBER are not all literals, so a constant message class and number pass while sy-msg* pass-through or a variable severity is flagged. Inline-text MESSAGE forms and `MESSAGE e001(zmsg)` are handled by pref-msg-cls, not by this rule.

### Non-Compliant

```abap
MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno INTO DATA(lv_message).
```

### Compliant

```abap
MESSAGE e001(zorder_msg) WITH lv_order_id INTO DATA(lv_message).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_DYN_MESSAGE

" SAP CI_ prefix format:
... "#EC CI_NO_DYN_MESSAGE
```

## Analysed statement form

Only `MESSAGE` with the explicit `ID ... TYPE ... NUMBER ...` operand list is inspected. The finding is raised when at least one of the three operands is not a literal.

| Statement | Finding |
| --- | --- |
| `MESSAGE ID 'ZORDER' TYPE 'E' NUMBER '001' INTO DATA(lv_text).` | none |
| `MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno INTO DATA(lv_text).` | `NO_DYN_MSG` |
| `MESSAGE ID 'ZORDER' TYPE lv_msgty NUMBER '001' INTO DATA(lv_text).` | `NO_DYN_MSG` |
| `MESSAGE e001(zorder_msg) INTO DATA(lv_text).` | none |

## Replacing the sy-msg pass-through

| Legacy pattern | Modern pattern |
| --- | --- |
| `MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno ...` | raise a typed exception: `RAISE EXCEPTION NEW zcx_order_error( iv_text = lv_text ).` |
| Re-raise the caught message in `CATCH` | `RAISE EXCEPTION NEW zcx_order_error( previous = lo_error ).` |
| Dynamic severity from `sy-msgty` | one static `MESSAGE w002(zorder_msg) INTO DATA(lv_text).` per case |

A message that must remain a message should always be written with a static class and number so that SE91 where-used, translation and the message checks keep working. Suppress a single statement with `"#EC NO_DYN_MESSAGE`.


## Related Rules

* [Use Centralized Message Classes Instead of Hardcoded Text Literals](/rules/pref-msg-cls) — <code>#EC PREF_MSG_CLS</code>
* [Raise Class-Based Exceptions Instead of Obsolete MESSAGE ... RAISING](/rules/no-msg-raising) — <code>#EC NO_MSG_RAISING</code>
* [Avoid Dynamic OpenSQL and Metaprogramming Language Constructs](/rules/no-dynamic-stmt) — <code>#EC NO_DYNAMIC_STMT</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_DYN_MESSAGE`
* **ABAP Implementation:** [/skyl/cl_no_dyn_message.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_dyn_message.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 5465)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L5465)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_DYN_MESSAGE&title=%5BBug%5D%3A%20Issue%20in%20no-dyn-message)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-dyn-message)**
