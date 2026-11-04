---
title: "Avoid Loops That Execute At Most Once Due to Unconditional Exit"
description: "Detect loops executing at most once due to unconditional EXIT or RETURN statements in Clean ABAP and SAP ATC."
keywords: "no-single-iter, single iteration loop, unconditional EXIT, Clean ABAP, SAP ATC"
category: "anti-patterns"
ruleId: "no-single-iter"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L170"
---

# Avoid Loops That Execute At Most Once Due to Unconditional Exit

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_SINGLE_ITER" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L170" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid Loops That Execute At Most Once.

> **ATC Finding Message:** `Loop contains an unconditional EXIT or RETURN and executes at most once`

## Rationale

A LOOP, WHILE, or DO statement containing an unconditional EXIT or RETURN at its top nesting level executes at most once, defeating the purpose of an iterative control structure. This anti-pattern typically stems from incomplete refactoring, abandoned prototyping code, or misusing a loop to read the first entry of an internal table. In ABAP Cloud and Clean ABAP, single-element lookups must use explicit table expressions with index 1 or line_exists( ), while conditional execution belongs in IF blocks or helper procedures. The check reports NO_1_LOOP on the early terminating statement.

### Non-Compliant

```abap
LOOP AT lt_sales_orders ASSIGNING <ls_sales_order>.
  process_order( <ls_sales_order> ).
  EXIT.
ENDLOOP.
```

### Compliant

```abap
IF line_exists( lt_sales_orders[ 1 ] ).
  process_order( lt_sales_orders[ 1 ] ).
ENDIF.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_SINGLE_ITER

" SAP CI_ prefix format:
... "#EC CI_NO_SINGLE_ITER
```

### Control Flow Inspection

The rule tracks control flow depth inside loop blocks (`LOOP`, `WHILE`, `DO`). If an unconditional `EXIT` or `RETURN` statement occurs outside any conditional branch (`IF`, `CASE`, `TRY`), finding `NO_1_LOOP` is reported.

| Construct | Issue | Recommended Alternative |
|---|---|---|
| `LOOP AT itab ... EXIT. ENDLOOP.` | Reads at most first element | Use table expression `itab[ 1 ]` or `READ TABLE ... INDEX 1` |
| `DO 1 TIMES ... EXIT. ENDDO.` | Pseudo-block used for jumps | Refactor into private helper method with early `RETURN` |

Suppress deliberate single-pass loop constructs using the pseudo-comment `"#EC NO_SINGLE_ITER`.


## Related Rules

* [Eliminate Unreachable Dead Code Caused by Constant False Conditions](/rules/no-dead-code) — <code>#EC NO_DEAD_CODE</code>
* [Avoid Unreachable Statements Following Unconditional Exit or Jump Operations](/rules/no-unreachable) — <code>#EC NO_UNREACHABLE</code>
* [Prefer Early Return and CONTINUE Guard Clauses over Nesting](/rules/pref-early-ret) — <code>#EC PREF_GUARD_METHOD</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_SINGLE_ITER`
* **ABAP Implementation:** [/skyl/cl_no_single_iter.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_single_iter.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 170)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L170)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_SINGLE_ITER&title=%5BBug%5D%3A%20Issue%20in%20no-single-iter)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-single-iter)**
