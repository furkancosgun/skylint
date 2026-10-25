---
title: "Prefer String Templates over CONCATENATE"
description: "Prefer String Templates over CONCATENATE - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-str-tmpl, clean-abap"
category: "clean-abap"
ruleId: "pref-str-tmpl"
---

# Prefer String Templates over CONCATENATE

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_STR_TMPL" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Prefer string templates over CONCATENATE.

> **ATC Finding Message:** `Use string template |...| instead of CONCATENATE`

## Rationale

CONCATENATE with SEPARATED BY is a procedural statement that splits a message into literals and variables and cannot be nested in expressions. String templates interpolate values directly, preserve spaces, and support formatting options for numbers, dates, and alignment. Use a template for readable text composition and reserve CONCATENATE only for legacy downport code.

### Non-Compliant

```abap
CONCATENATE 'Order' lv_order_id 'created' INTO lv_message SEPARATED BY space.
```

### Compliant

```abap
lv_message = |Order { lv_order_id } created|.
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
... "#EC PREF_STR_TMPL

" SAP CI_ prefix format:
... "#EC CI_PREF_STR_TMPL
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_STR_TMPL`
* **Implementation File:** [zcl_skylint_pref_str_tmpl.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_str_tmpl.clas.abap)
