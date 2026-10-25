---
title: "Avoid Concatenating Adjacent String Literals"
description: "Avoid Concatenating Adjacent String Literals - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-useless-concat, anti-patterns"
category: "anti-patterns"
ruleId: "no-useless-concat"
---

# Avoid Concatenating Adjacent String Literals

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="info" text="Note" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_USELESS_CONCAT" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid concatenating string literals.

> **ATC Finding Message:** `Fold literal string concatenation into one literal`

## Rationale

Joining two or more literals with && produces one constant value at runtime, so the operator adds no information and only fragments the text. Folding the literals makes the final string visible and removes a pointless expression. Keep && only when at least one operand is dynamic.

### Non-Compliant

```abap
lv_path = 'orders' && '/' && 'open'.
```

### Compliant

```abap
lv_path = 'orders/open'.
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
... "#EC NO_USELESS_CONCAT

" SAP CI_ prefix format:
... "#EC CI_NO_USELESS_CONCAT
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_USELESS_CONCAT`
* **Implementation File:** [zcl_skylint_no_useless_concat.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_useless_concat.clas.abap)
