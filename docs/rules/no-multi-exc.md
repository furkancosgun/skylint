---
title: "Raise Only One Exception Type per Method"
description: "Report methods that raise more than one distinct exception class - enforce a single exception type per ABAP method for simpler TRY CATCH handling."
keywords: "ABAP exception design, RAISE EXCEPTION TYPE, no-multi-exc, single exception class, Clean ABAP"
category: "clean-abap"
ruleId: "no-multi-exc"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5437"
---

# Raise Only One Exception Type per Method

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC NO_MULTI_EXC" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5437" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Raise At Most One Exception Type per Method.

> **ATC Finding Message:** `Method raises several different exception classes - raise one type instead`

## Rationale

Every distinct exception class raised by a method becomes part of its public contract, so callers have to write one CATCH block per type, keep the handler order correct and duplicate cleanup logic in each branch. A single exception type per method, with the error detail carried in attributes or a reason code, keeps the signature stable when a new failure mode appears and lets callers handle everything in one place. The check collects the class name of every RAISE EXCEPTION TYPE/NEW statement per procedure and reports NO_MULTEXC on the first statement that introduces a type different from the one raised first. Both the TYPE and the NEW operand forms are analysed, so modern and legacy raising styles are covered.

### Non-Compliant

```abap
IF lv_order_total <= 0.
  RAISE EXCEPTION NEW zcx_order_invalid_total( ).
ENDIF.
IF lv_customer_id IS INITIAL.
  RAISE EXCEPTION NEW zcx_order_missing_customer( ).
ENDIF.
```

### Compliant

```abap
IF lv_order_total <= 0.
  RAISE EXCEPTION NEW zcx_order_invalid( iv_reason = 'TOTAL' ).
ENDIF.
IF lv_customer_id IS INITIAL.
  RAISE EXCEPTION NEW zcx_order_invalid( iv_reason = 'CUSTOMER' ).
ENDIF.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_MULTI_EXC

" SAP CI_ prefix format:
... "#EC CI_NO_MULTI_EXC
```

## How the finding is computed

1. The first `RAISE EXCEPTION TYPE` / `RAISE EXCEPTION NEW` statement of the procedure defines the accepted exception class.
2. Every later `RAISE` that names a different class is reported as `NO_MULTEXC`.

| Sequence of raised classes | Findings |
| --- | --- |
| `zcx_order_invalid`, `zcx_order_invalid` | none |
| `zcx_order_invalid`, `zcx_missing_customer` | 1 (on `zcx_missing_customer`) |
| `zcx_a`, `zcx_b`, `zcx_c` | 2 (on `zcx_b` and `zcx_c`) |

## Recommended design

- Raise one dedicated exception class per method and transport the cause in an attribute (`iv_reason`, `iv_failed_field`, `iv_order_id`).
- If callers really must distinguish cases, define a small exception hierarchy (`zcx_order_error` as superclass, `zcx_order_total` and `zcx_order_customer` as subclasses) and raise the superclass type - one RAISE statement, the caller catches the superclass.
- `RAISE EXCEPTION TYPE` and `RAISE EXCEPTION NEW` are both analysed; `RAISE` with a resumable or `MESSAGE ... RAISING` pattern is out of scope.
- Suppress legacy code with `"#EC NO_MULTI_EXC` on the second `RAISE` statement.


## Related Rules

* [Prefer Class-Based Exceptions over Classic EXCEPTIONS](/rules/pref-class-exc) — <code>#EC PREF_CLASS_EXC</code>
* [Assign Distinct Error Numbers in Classic Function EXCEPTIONS Clauses](/rules/no-exc-overlap) — <code>#EC NO_EXC_OVERLAP</code>
* [Raise Class-Based Exceptions Instead of Obsolete MESSAGE ... RAISING](/rules/no-msg-raising) — <code>#EC NO_MSG_RAISING</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_MULTI_EXC`
* **ABAP Implementation:** [/skyl/cl_no_multi_exc.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_multi_exc.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 5437)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L5437)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_MULTI_EXC&title=%5BBug%5D%3A%20Issue%20in%20no-multi-exc)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-multi-exc)**
