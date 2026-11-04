---
title: "Capture sy-tabix and sy-index Immediately at Loop Start"
description: "Prevent fragile sy-tabix and sy-index reads inside ABAP loops by copying loop indices immediately at block entry."
keywords: "sy-tabix, sy-index, ABAP loop index, Clean ABAP, SAP ATC check, no-late-sys-idx"
category: "anti-patterns"
ruleId: "no-late-sys-idx"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3925"
---

# Capture sy-tabix and sy-index Immediately at Loop Start

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_LATE_SYS_IDX" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3925" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid late access to sy-tabix or sy-index inside loops.

> **ATC Finding Message:** `Copy sy-tabix or sy-index immediately at loop start`

## Rationale

System fields sy-tabix and sy-index are globally mutable and volatile; intervening statements, method invocations, subroutines, or secondary table reads inside a loop can alter or reset them. Accessing sy-tabix or sy-index later in a loop body rather than immediately on the first statement introduces subtle runtime bugs and fragile temporal coupling. Clean ABAP requires copying index values into an explicit local variable at loop initialization.

### Non-Compliant

```abap
LOOP AT lt_order_items ASSIGNING FIELD-SYMBOL(<ls_order_item>).
  process_item( <ls_order_item> ).
  DATA(lv_current_index) = sy-tabix.
ENDLOOP.
```

### Compliant

```abap
LOOP AT lt_order_items ASSIGNING FIELD-SYMBOL(<ls_order_item>).
  DATA(lv_current_index) = sy-tabix.
  process_item( <ls_order_item> ).
ENDLOOP.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_LATE_SYS_IDX

" SAP CI_ prefix format:
... "#EC CI_NO_LATE_SYS_IDX
```

### Evaluation details

The check verifies that reads of `sy-tabix` within `LOOP` blocks and `sy-index` within `DO` or `WHILE` blocks occur immediately as the first statement of the iteration body:

| Loop Structure | Immediate Read (First statement) | Late Read (Subsequent statement) |
| --- | --- | --- |
| `LOOP AT itab ...` | Allowed: `DATA(lv_idx) = sy-tabix.` | Flagged: `NO_LATE_SY` |
| `DO 10 TIMES ...` | Allowed: `DATA(lv_idx) = sy-index.` | Flagged: `NO_LATE_SY` |
| `WHILE ...` | Allowed: `DATA(lv_idx) = sy-index.` | Flagged: `NO_LATE_SY` |

Reads occurring outside loops are ignored by this check (governed by other system field rules).

### Suppression

To keep a late system index read when side effects are demonstrably impossible, add pseudo-comment `"#EC NO_LATE_SYS_IDX` to the statement reading the system field.


## Related Rules

* [Avoid String Accumulation Inside Loops (Quadratic Memory Growth)](/rules/no-concat-loop) — <code>#EC NO_CONCAT_LOOP</code>
* [Avoid WITH DEFAULT KEY in Internal Table Declarations](/rules/no-default-key) — <code>#EC NO_DEFAULT_KEY</code>
* [Use lines( ) Instead of DESCRIBE TABLE LINES](/rules/pref-lines) — <code>#EC PREF_LINES</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_LATE_SYS_IDX`
* **ABAP Implementation:** [/skyl/cl_no_late_sys_idx.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_late_sys_idx.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3925)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3925)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_LATE_SYS_IDX&title=%5BBug%5D%3A%20Issue%20in%20no-late-sys-idx)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-late-sys-idx)**
