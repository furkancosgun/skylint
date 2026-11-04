---
title: "Replace Manual IF Range Clamping with nmin( ) and nmax( )"
description: "Detect manual IF ELSEIF range clamping in ABAP and rewrite it with nmin and nmax - branch-free, testable value clamping with an automatic quickfix."
keywords: "ABAP clamp, nmin nmax, manual range check, pref-clamp, Clean ABAP expressions"
category: "clean-abap"
ruleId: "pref-clamp"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5616"
---

# Replace Manual IF Range Clamping with nmin( ) and nmax( )

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_CLAMP" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5616" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Prefer nmin/nmax over manual IF clamp.

> **ATC Finding Message:** `Manual range clamping detected; consider using nmin( ) and nmax( )`

## Rationale

Clamping a value by hand costs five statements, introduces two branches that must be reviewed and tested separately, and can silently drift when one bound changes but the other does not. The built-in functions nmin( ) and nmax( ) express the same range containment as a single expression without control flow, so it can be inlined into a constructor expression, debugged in one step and unit tested as pure arithmetic. The check reports PREF_CLAMP only for the exact five-statement pattern IF / assignment / ELSEIF / assignment / ENDIF where both conditions compare the same variable with the assigned bound in opposite directions. The TO_NMINMAX quickfix rewrites the whole block, keeping the original indentation, so the migration is a single click.

### Non-Compliant

```abap
DATA lv_discount_pct TYPE i VALUE 130.
IF lv_discount_pct < 0.
  lv_discount_pct = 0.
ELSEIF lv_discount_pct > 100.
  lv_discount_pct = 100.
ENDIF.
```

### Compliant

```abap
DATA lv_discount_pct TYPE i VALUE 130.
lv_discount_pct = nmin( val1 = 100
                        val2 = nmax( val1 = 0
                                     val2 = lv_discount_pct ) ).
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

## Exact pattern

All five statements must be adjacent and match this shape:

```abap
IF lv_discount_pct < 0.
  lv_discount_pct = 0.
ELSEIF lv_discount_pct > 100.
  lv_discount_pct = 100.
ENDIF.
```

- The comparison operator may be `<`, `LT`, `<=`, `LE`, `>`, `GT`, `>=` or `GE`, and the variable may stand on either side of the operator - the direction is normalised.
- Both conditions must compare the *same* variable, and each branch must assign the *other* bound to it.
- Parentheses around the conditions (`IF ( lv < lo ).`) are stripped before analysis.

## Not reported

| Shape | Why |
| --- | --- |
| Two separate `IF ... ENDIF` blocks | there is no `ELSEIF` chain |
| `IF ... ELSEIF ... ELSE ... ENDIF` | the chain has a third branch |
| Branch assigns a literal instead of the compared bound | not a clamp |
| Condition and assignment use different variables | no clamp pattern |

## QuickFix

`TO_NMINMAX` replaces the five statements with one expression, preserving indentation:

```abap
lv_discount_pct = nmin( val1 = 100 val2 = nmax( val1 = 0 val2 = lv_discount_pct ) ).
```


## Related Rules

* [Use BETWEEN for Inclusive Range Checks](/rules/pref-between) — <code>#EC PREF_BETWEEN</code>
* [Collapse Value-Mapping IF Chains into COND](/rules/pref-cond) — <code>#EC PREF_COND</code>
* [Convert Pure CASE Mappings into SWITCH Expressions](/rules/pref-switch) — <code>#EC PREF_SWITCH</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_CLAMP`
* **ABAP Implementation:** [/skyl/cl_pref_clamp.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_clamp.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 5616)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L5616)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_CLAMP&title=%5BBug%5D%3A%20Issue%20in%20pref-clamp)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-clamp)**
