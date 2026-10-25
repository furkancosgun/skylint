---
title: "Avoid Chained Declarations (DATA:, CONSTANTS:, TYPES:)"
description: "Avoid Chained Declarations (DATA:, CONSTANTS:, TYPES:) - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-chained-decl, anti-patterns"
category: "anti-patterns"
ruleId: "no-chained-decl"
---

# Avoid Chained Declarations (DATA:, CONSTANTS:, TYPES:)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_CHAINED_DECL" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid Chained Declarations.

> **ATC Finding Message:** `Avoid chained declarations; declare each entity individually`

## Rationale

Chained declarations combine multiple definitions behind a colon and commas, obscuring types and causing noisy version control diffs for single-variable modifications. In modern Clean ABAP, each variable, constant, or type definition should be an independent, fully qualified statement for maximum readability and clean diff tracking.

### Non-Compliant

```abap
DATA: lv_order_id TYPE string,
      lv_status   TYPE string.
```

### Compliant

```abap
DATA lv_order_id TYPE string.
DATA lv_status TYPE string.
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `ALLOW_STRUCTURE_CHAINS` | `Boolean` | <code>true</code> | Allow chained declarations exclusively inside BEGIN OF ... END OF structure definitions |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_CHAINED_DECL

" SAP CI_ prefix format:
... "#EC CI_NO_CHAINED_DECL
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_CHAINED_DECL`
* **Implementation File:** [zcl_skylint_no_chained_decl.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_chained_decl.clas.abap)
