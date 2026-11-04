---
title: "Avoid Yoda Conditions by Placing Variables Before Literals"
description: "Prevent Yoda conditions in comparisons by placing variables before constants in ABAP Cloud."
keywords: "no-yoda-cond, Yoda conditions, comparison expressions, Clean ABAP, SAP ATC"
category: "anti-patterns"
ruleId: "no-yoda-cond"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L976"
---

# Avoid Yoda Conditions by Placing Variables Before Literals

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_YODA_COND" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L976" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid Yoda conditions in comparison expressions.

> **ATC Finding Message:** `Avoid Yoda conditions; place variable before literal in comparison`

## Rationale

Yoda conditions place literals or constants on the left side of comparison operators, reversing the natural subject-verb-object reading order of ABAP logic. While originally adopted in C-family languages to prevent accidental assignment in conditional expressions, ABAP syntax strictly prohibits assignment inside IF or WHILE conditions, rendering Yoda conditions obsolete and confusing. Clean ABAP mandates variable-first comparisons to maintain idiomatic readability across ABAP Cloud and modern ATC-inspected programs.

### Non-Compliant

```abap
IF 'CONFIRMED' = lv_delivery_status.
  ship_sales_order( ).
ENDIF.
```

### Compliant

```abap
IF lv_delivery_status = 'CONFIRMED'.
  ship_sales_order( ).
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
... "#EC NO_YODA_COND

" SAP CI_ prefix format:
... "#EC CI_NO_YODA_COND
```

### QuickFix Operator Inversion

The `UNYODA` QuickFix automatically transposes the operands and inverts directional comparison operators where required:

| Original Operator | Transposed Operator |
|---|---|
| `=` / `EQ` | `=` / `EQ` |
| `<>` / `NE` | `<>` / `NE` |
| `<` / `LT` | `>` / `GT` |
| `>` / `GT` | `<` / `LT` |
| `<=` / `LE` | `>=` / `GE` |
| `>=` / `GE` | `<=` / `LE` |

The rule inspects executable statements where a literal is followed by a comparison operator and a non-literal token. Suppress with `"#EC NO_YODA_COND`.


## Related Rules

* [Avoid Duplicate Conditions in Branching Statements and Logical Operators](/rules/no-dup-cond) — <code>#EC NO_DUP_COND</code>
* [Avoid Negated IF Conditions with an ELSE Branch by Inverting Condition and Swapping Branches](/rules/no-neg-cond) — <code>#EC NO_NEG_COND</code>
* [Collapse Value-Mapping IF Chains into COND](/rules/pref-cond) — <code>#EC PREF_COND</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_YODA_COND`
* **ABAP Implementation:** [/skyl/cl_no_yoda_cond.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_yoda_cond.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 976)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L976)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_YODA_COND&title=%5BBug%5D%3A%20Issue%20in%20no-yoda-cond)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-yoda-cond)**
