---
title: "Avoid Overwriting Variable Values Before They Are Read"
description: "Identify ABAP dead stores where variables are overwritten before being read, revealing dead code and refactoring bugs."
keywords: "ABAP dead store, overwritten assignment, unused assignment, Clean ABAP, SAP ATC check, no-dead-store"
category: "anti-patterns"
ruleId: "no-dead-store"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4599"
---

# Avoid Overwriting Variable Values Before They Are Read

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_DEAD_STORE" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4599" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid assignments that are never read.

> **ATC Finding Message:** `This value is overwritten before it is read; remove the assignment or read it`

## Rationale

Assigning a value to a variable and then immediately overwriting it without an intervening read operation constitutes a dead store. Dead stores waste computation and memory bandwidth, but more critically, they often conceal logic flaws where an intermediate calculation or validation check was accidentally bypassed during code refactoring. Remove the redundant assignment or read the variable.

### Non-Compliant

```abap
DATA lv_order_status TYPE string.
lv_order_status = 'PENDING'.
lv_order_status = 'CONFIRMED'.
log_order_status( lv_order_status ).
```

### Compliant

```abap
DATA lv_order_status TYPE string.
lv_order_status = 'CONFIRMED'.
log_order_status( lv_order_status ).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_DEAD_STORE

" SAP CI_ prefix format:
... "#EC CI_NO_DEAD_STORE
```

### Detection logic

The check inspects assignment statements (`COMPUTE` and legacy `MOVE`) for local variables:
1. An assignment sets a pending store state on a variable.
2. A subsequent write before any read marks the first assignment as a dead store (`NO_DEAD_ST`).
3. Intervening block boundaries (`IF`, `CASE`, `LOOP`, `TRY`) and conditional writes (`SELECT`, `READ TABLE`) reset pending stores to prevent false positives across branches.
4. If a variable is never read anywhere in the procedure, this check leaves it to `no-unused-vars`.

| Sequence | Result |
| --- | --- |
| `val = 1. val = 2. log( val ).` | First assignment flagged (`NO_DEAD_ST`) |
| `val = 1. log( val ). val = 2. log( val ).` | Compliant (read between assignments) |
| `val = 1. IF flag = abap_true. val = 2. ENDIF.` | Compliant (branch boundary resets pending store) |

### Suppression

If an initial assignment is required by an external macro or interface, annotate with `"#EC NO_DEAD_STORE`.


## Related Rules

* [Remove Unread Local Variables and Field Symbols](/rules/no-unused-vars) — <code>#EC NO_UNUSED_VARS</code>
* [Eliminate Unreachable Dead Code Caused by Constant False Conditions](/rules/no-dead-code) — <code>#EC NO_DEAD_CODE</code>
* [Declare Single-Assignment Local Variables with FINAL( )](/rules/pref-final-data) — <code>#EC PREF_FINAL_DATA</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_DEAD_STORE`
* **ABAP Implementation:** [/skyl/cl_no_dead_store.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_dead_store.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4599)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4599)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_DEAD_STORE&title=%5BBug%5D%3A%20Issue%20in%20no-dead-store)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-dead-store)**
