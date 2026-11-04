---
title: "Extract Identical Statements Shared Across All IF and ELSE Branches"
description: "Extract identical statements shared across all IF and ELSE branches in Clean ABAP and SAP ATC."
keywords: "no-ident-cont, identical branch statements, code duplication, Clean ABAP, SAP ATC"
category: "anti-patterns"
ruleId: "no-ident-cont"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L836"
---

# Extract Identical Statements Shared Across All IF and ELSE Branches

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_IDENT_CONT" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L836" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid identical code in IF and ELSE branches.

> **ATC Finding Message:** `Identical statement in IF and ELSE branches; extract common code`

## Rationale

When the first or last statement of every branch in an IF / ELSEIF / ELSE structure is identical, the logic is being executed unconditionally regardless of which branch evaluates to true. Duplicating statements across branches clutters control structures, obscures which operations are truly branch-dependent, and creates maintenance overhead when the common operation must be changed. In Clean ABAP, hoist identical leading statements before the IF block and trailing statements after the ENDIF. The check flags duplicate branch boundaries with finding NO_IDN_CNT.

### Non-Compliant

```abap
IF lv_order_status = 'APPROVED'.
  persist_order_changes( ).
  log_order_event( 'Approved' ).
ELSE.
  persist_order_changes( ).
  log_order_event( 'Rejected' ).
ENDIF.
```

### Compliant

```abap
persist_order_changes( ).
IF lv_order_status = 'APPROVED'.
  log_order_event( 'Approved' ).
ELSE.
  log_order_event( 'Rejected' ).
ENDIF.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_IDENT_CONT

" SAP CI_ prefix format:
... "#EC CI_NO_IDENT_CONT
```

### Common Statement Extraction

The rule inspects all branches (`IF`, `ELSEIF`, and `ELSE`). If every branch begins with the exact same statement, or if every branch ends with the exact same statement, finding `NO_IDN_CNT` is reported on the opening `IF`.

```abap
" Anti-pattern: Common statement duplicated in all branches
IF lv_is_expedited = abap_true.
  send_notification( ).
  lv_priority = 1.
ELSE.
  send_notification( ).
  lv_priority = 2.
ENDIF.

" Clean ABAP: Extracted outside the conditional block
send_notification( ).
IF lv_is_expedited = abap_true.
  lv_priority = 1.
ELSE.
  lv_priority = 2.
ENDIF.
```

Control structure boundary keywords (`IF`, `LOOP`, `CASE`, `TRY`) are excluded from extraction. Suppress findings using `"#EC NO_IDENT_CONT`.


## Related Rules

* [Replace Single-Branch CASE Statements with IF Conditions](/rules/no-single-when) — <code>#EC NO_SINGLE_WHEN</code>
* [Avoid CHECK Statements Inside and Outside Iteration Loops](/rules/no-check-stmt) — <code>#EC NO_CHECK_IN_LOOP</code>
* [Avoid Comparing Boolean Method Calls to abap_true or abap_false](/rules/no-bool-compare) — <code>#EC NO_BOOL_COMPARE</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_IDENT_CONT`
* **ABAP Implementation:** [/skyl/cl_no_ident_cont.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_ident_cont.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 836)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L836)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_IDENT_CONT&title=%5BBug%5D%3A%20Issue%20in%20no-ident-cont)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-ident-cont)**
