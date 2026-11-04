---
title: "Limit Jump Statements (CONTINUE, EXIT) per Loop"
description: "Limit CONTINUE and EXIT statements per ABAP loop to reduce control flow complexity."
keywords: "ABAP Loop jumps, LoopWithTooManyJumps, CONTINUE EXIT limit, Clean ABAP"
category: "metrics"
ruleId: "max-loop-jumps"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5371"
---

# Limit Jump Statements (CONTINUE, EXIT) per Loop

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC MAX_LOOP_JUMPS" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5371" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Limit jump statements (CONTINUE/EXIT) per loop.

> **ATC Finding Message:** `Loop has too many jump statements (CONTINUE/EXIT); simplify loop control flow`

## Rationale

Loops containing too many jump statements (CONTINUE, EXIT) have convoluted control flow that makes loop invariants difficult to reason about and maintain. Restructure the loop body using helper methods or simplified boolean conditions.

### Non-Compliant

```abap
LOOP AT lt_items INTO ls_item.
  IF cond1. CONTINUE. ENDIF.
  IF cond2. EXIT. ENDIF.
  IF cond3. CONTINUE. ENDIF.
ENDLOOP.
```

### Compliant

```abap
LOOP AT lt_items INTO ls_item WHERE ...
  process_item( ls_item ).
ENDLOOP.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `MAX_LOOP_JUMPS` | `Integer` | <code>2</code> | Maximum number of jump statements (CONTINUE/EXIT) allowed per loop (default: 2) |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MAX_LOOP_JUMPS

" SAP CI_ prefix format:
... "#EC CI_MAX_LOOP_JUMPS
```


## Related Rules

* [Avoid CHECK Statements](/rules/no-check-stmt) — <code>#EC NO_CHECK_IN_LOOP</code>
* [Disallow Nested LOOP AT Statements Without FROM or GROUP BY](/rules/no-nested-loop) — <code>#EC NO_NESTED_LOOP</code>
* [Limit Cyclomatic Complexity (McCabe Complexity Metric)](/rules/max-cyclo-comp) — <code>#EC MAX_CYCLO_COMP</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_MAX_LOOP_JUMPS`
* **ABAP Implementation:** [/skyl/cl_max_loop_jumps.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_max_loop_jumps.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 5371)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L5371)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_MAX_LOOP_JUMPS&title=%5BBug%5D%3A%20Issue%20in%20max-loop-jumps)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20max-loop-jumps)**
