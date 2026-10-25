---
title: "Prefer RETURN over EXIT in Methods"
description: "Prefer RETURN over EXIT in Methods - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-return, clean-abap"
category: "clean-abap"
ruleId: "pref-return"
---

# Prefer RETURN over EXIT in Methods

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_RETURN" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Prefer RETURN over EXIT outside loop constructs.

> **ATC Finding Message:** `Use RETURN instead of EXIT when leaving a procedure`

## Rationale

EXIT has loop-specific meaning and can leave a method at a point that is easy to overlook when the surrounding code changes. RETURN explicitly ends the current procedure and cannot be confused with loop control. Use RETURN for method exit and LEAVE LOOP or CONTINUE for loop control.

### Non-Compliant

```abap
IF is_invalid( ).
  EXIT.
ENDIF.
process( ).
```

### Compliant

```abap
IF is_invalid( ).
  RETURN.
ENDIF.
process( ).
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
... "#EC PREF_RETURN

" SAP CI_ prefix format:
... "#EC CI_PREF_RETURN
```


## Related Rules

* [Do Not Ignore Return Value of Functional Methods](/rules/no-ignored-return) — <code>#EC NO_IGNORED_RETURN</code>
* [Omit Unnecessary RETURN Statement](/rules/no-unnec-return) — <code>#EC NO_UNNEC_RETURN</code>
* [Prefer Early Return to Reduce Nesting (Guard Clauses)](/rules/pref-early-ret) — <code>#EC PREF_GUARD_METHOD</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_RETURN`
* **Implementation File:** [zcl_skylint_pref_return.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_return.clas.abap)
