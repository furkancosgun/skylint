---
title: "Prefer Inline Declarations over Separate DATA and Assignment"
description: "Merge separate DATA declarations with their first assignment into inline DATA( ) declarations to shorten ABAP methods and infer types automatically."
keywords: "pref-inline, inline declaration, DATA( ), Clean ABAP, ABAP 7.40"
category: "clean-abap"
ruleId: "pref-inline"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2814"
---

# Prefer Inline Declarations over Separate DATA and Assignment

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_INLINE" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2814" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Prefer Inline Declarations.

> **ATC Finding Message:** `Prefer inline declaration over separate DATA and assignment`

## Rationale

Declaring a variable at the top of a method and assigning it several statements later separates the declaration from its first use and widens its lifetime, which makes the method harder to reason about. An inline declaration keeps the variable next to the expression that produces it, lets the compiler infer the type, and removes the risk that the declared type drifts from the assigned one. The check only reports declarations whose first use is a pure write, so variables that are read before they are filled are never touched.

### Non-Compliant

```abap
DATA lv_gross_amount TYPE p LENGTH 8 DECIMALS 2.
lv_gross_amount = lv_net_amount * lv_tax_factor.
```

### Compliant

```abap
DATA(lv_gross_amount) = lv_net_amount * lv_tax_factor.
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
... "#EC PREF_INLINE

" SAP CI_ prefix format:
... "#EC CI_PREF_INLINE
```

### When the check fires

`PREF_INLIN` is raised only when the declaration is followed — at the same nesting depth — by a first use that is a pure write of the variable:

| First use | Replacement |
| --- | --- |
| `lv_x = <expression>` | `DATA(lv_x) = <expression>` |
| `READ TABLE ... INTO lv_x` | `READ TABLE ... INTO DATA(lv_x)` |
| `LOOP AT ... INTO lv_x` | `LOOP AT ... INTO DATA(lv_x)` |
| `CATCH ... INTO lv_x` | `CATCH ... INTO DATA(lv_x)` |

The check stays silent when the variable is read inside the first statement (`lv_total = lv_total + 1`), when it is used in a nested block before the write, when it is declared inside a structure (`BEGIN OF`), or when the assignment uses the casting operator `?=`. Suppress a single declaration with `"#EC PREF_INLINE`.


## Related Rules

* [Declare Character Lengths with Explicit LENGTH Clause Instead of Parenthesized Syntax](/rules/no-inline-len) — <code>#EC NO_INLINE_LEN</code>
* [Avoid Chained Declarations for Variables, Types, and Constants](/rules/no-chained-decl) — <code>#EC NO_CHAINED_DECL</code>
* [Enforce Routine Declaration Hierarchy and Top-of-Block Placement](/rules/pref-declarations) — <code>#EC DEF_TOP</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_INLINE`
* **ABAP Implementation:** [/skyl/cl_pref_inline.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_inline.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 2814)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L2814)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_INLINE&title=%5BBug%5D%3A%20Issue%20in%20pref-inline)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-inline)**
