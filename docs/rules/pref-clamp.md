---
title: "Prefer nmin/nmax or clamp Expressions over Manual IF Clamping"
description: "Prefer built-in nmin, nmax, or clamp functions over manual range checking IF statements in ABAP."
keywords: "ABAP clamp, nmin nmax ABAP, manual clamp, Clean ABAP expressions"
category: "clean-abap"
ruleId: "pref-clamp"
---

# Prefer nmin/nmax or clamp Expressions over Manual IF Clamping

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_CLAMP" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Prefer nmin/nmax over manual IF clamp.

> **ATC Finding Message:** `Manual range clamping detected; consider using nmin( ) and nmax( )`

## Rationale

Manually clamping a variable between lower and upper bounds using IF/ELSEIF statements is verbose and imperative. Modern ABAP provides built-in functions like nmin( ) and nmax( ) or clamp( ) that express range containment concisely and without branch complexity.

### Non-Compliant

```abap
IF lv < lo.
  lv = lo.
ELSEIF lv > hi.
  lv = hi.
ENDIF.
```

### Compliant

```abap
lv = nmin( val1 = hi
           val2 = nmax( val1 = lo
                        val2 = lv ) ).
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
... "#EC PREF_CLAMP

" SAP CI_ prefix format:
... "#EC CI_PREF_CLAMP
```


## Related Rules

* [Prefer BETWEEN for Inclusive Range Checks](/rules/pref-between) — <code>#EC PREF_BETWEEN</code>
* [Prefer COND #( ) Expression over IF/ELSEIF/ELSE](/rules/pref-cond) — <code>#EC PREF_COND</code>
* [Prefer SWITCH #( ) Expression over CASE Statement](/rules/pref-switch) — <code>#EC PREF_SWITCH</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_CLAMP`
* **Implementation File:** [zcl_skylint_pref_clamp.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_clamp.clas.abap)
