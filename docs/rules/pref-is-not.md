---
description: "Prefer IS NOT over NOT ... IS"
---

# Prefer IS NOT over NOT ... IS

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC IS_NOT" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Prefer IS NOT over NOT ... IS.

> **ATC Finding Message:** `Use IS NOT instead of NOT ... IS`

## Rationale

Writing NOT before a complete IS expression forces the reader to negate the condition mentally and can be misread in compound logic. IS NOT keeps the subject first and reads in natural order, as in lo_instance IS NOT BOUND. Prefer IS NOT for predicates such as IS BOUND, IS INITIAL, and IS ASSIGNED.

### Non-Compliant

```abap
IF NOT lt_items IS INITIAL.
  process_items( lt_items ).
ENDIF.
```

### Compliant

```abap
IF lt_items IS NOT INITIAL.
  process_items( lt_items ).
ENDIF.
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC IS_NOT

" SAP CI_ prefix format:
... "#EC CI_IS_NOT
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_IS_NOT`
* **Implementation File:** [zcl_skylint_pref_is_not.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_is_not.clas.abap)
