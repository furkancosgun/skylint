---
title: "Prefer IS [NOT] INITIAL Over lines( ) and Empty Literal Comparisons"
description: "Replace lines() comparisons and empty literal checks with IS NOT INITIAL and IS INITIAL for cleaner, high-performance ABAP Cloud code."
keywords: "pref-is-initial, IS INITIAL, IS NOT INITIAL, lines(), Clean ABAP"
category: "clean-abap"
ruleId: "pref-is-initial"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3256"
---

# Prefer IS [NOT] INITIAL Over lines( ) and Empty Literal Comparisons

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_IS_INITIAL" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3256" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Prefer IS [NOT] INITIAL over lines( ) or empty literals.

> **ATC Finding Message:** `Use IS [NOT] INITIAL instead of lines( ) or empty literal comparison`

## Rationale

Comparing lines( itab ) against zero or testing variables against empty string literals ('', ``, SPACE) or numeric zero obscures developer intent and introduces counting overhead on large tables. In contrast, the predicate IS [NOT] INITIAL is type-agnostic, evaluates emptiness directly at the kernel level without table iteration, and clearly conveys intent. Skylint detects lines( ) inequalities and empty literal comparisons in IF, ELSEIF, CHECK, and WHILE statements, reporting PREF_INIT alongside the REPLINIT quickfix.

### Non-Compliant

```abap
IF lines( lt_sales_orders ) > 0.
  process_orders( lt_sales_orders ).
ENDIF.
```

### Compliant

```abap
IF lt_sales_orders IS NOT INITIAL.
  process_orders( lt_sales_orders ).
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
... "#EC PREF_IS_INITIAL

" SAP CI_ prefix format:
... "#EC CI_PREF_IS_INITIAL
```

## Supported Patterns and Quickfix

The check flags the following patterns in control flow statements (`IF`, `ELSEIF`, `CHECK`, `WHILE`):

| Expression Pattern | Recommended Replacement |
|---|---|
| `lines( itab ) > 0`, `>= 1`, `<> 0` | `itab IS NOT INITIAL` |
| `lines( itab ) = 0`, `<= 0`, `< 1` | `itab IS INITIAL` |
| `var = ''`, `var = ' '`, `var = 0`, `var = SPACE` | `var IS INITIAL` |
| `var <> ''`, `var <> 0`, `var <> SPACE` | `var IS NOT INITIAL` |

The `REPLINIT` quickfix automatically converts these conditions to standard `IS [NOT] INITIAL` expressions.

Suppress findings using pseudo comment `"#EC PREF_IS_INITIAL`.


## Related Rules

* [Rewrite NOT ... IS Predicates as IS NOT](/rules/pref-is-not) — <code>#EC PREF_IS_NOT</code>
* [Prefer CASE over Multiple IF / ELSEIF on the Same Variable](/rules/pref-case) — <code>#EC PREF_CASE</code>
* [Collapse Value-Mapping IF Chains into COND](/rules/pref-cond) — <code>#EC PREF_COND</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_IS_INITIAL`
* **ABAP Implementation:** [/skyl/cl_pref_is_initial.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_is_initial.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3256)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3256)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_IS_INITIAL&title=%5BBug%5D%3A%20Issue%20in%20pref-is-initial)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-is-initial)**
