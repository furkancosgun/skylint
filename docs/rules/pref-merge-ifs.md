---
title: "Merge Nested IF Statements"
description: "Merge Nested IF Statements - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-merge-ifs, clean-abap"
---

# Merge Nested IF Statements

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_MERGE_IFS" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Merge consecutive nested IF blocks using boolean AND.

> **ATC Finding Messages:**
> - `Nested IF block can be merged with outer IF using AND`
> - `Nested IF in ELSE block can be changed to ELSEIF`

## Rationale

Nested IF statements without intermediate statements add indentation without adding meaning. Merging them with AND or converting a nested IF in an ELSE block into ELSEIF flattens the control flow and makes the combined condition explicit. Less nesting reduces cyclomatic complexity and makes the happy path easier to test.

### Non-Compliant

```abap
IF is_active( ).
  IF is_authorized( ).
    process_order( ).
  ENDIF.
ENDIF.
```

### Compliant

```abap
IF is_active( ) AND is_authorized( ).
  process_order( ).
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
... "#EC PREF_MERGE_IFS

" SAP CI_ prefix format:
... "#EC CI_PREF_MERGE_IFS
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_MERGE_IFS`
* **Implementation File:** [zcl_skylint_pref_merge_ifs.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_merge_ifs.clas.abap)
