---
title: "Inline Declaration With Packed Arithmetic Loses Decimals"
description: "Report inline declarations with packed arithmetic which default to 0 decimals and lose precision."
keywords: "no-inline-packed, packed arithmetic, DECIMALS 0, DATA(...) packed truncation"
category: "anti-patterns"
ruleId: "no-inline-packed"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L6039"
---

# Inline Declaration With Packed Arithmetic Loses Decimals

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_INLINE_PACKED" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L6039" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Inline declaration with packed arithmetic loses decimals.

> **ATC Finding Message:** `DATA(...) with packed arithmetic defaults to P(8,0) and loses decimals`

## Rationale

When an arithmetic expression involving packed numbers (TYPE p) is assigned to an inline declaration DATA(...), ABAP derives the target variable type as P LENGTH 8 DECIMALS 0. As a consequence, all decimal places are silently truncated, resulting in loss of precision in financial and mathematical computations. Use an explicit DATA declaration with DECIMALS or CONV #( ... ).

### Non-Compliant

```abap
DATA lv_price TYPE p DECIMALS 2 VALUE '12.50'.
DATA(lv_total) = lv_price * 10 / 3.
```

### Compliant

```abap
DATA lv_price TYPE p DECIMALS 2 VALUE '12.50'.
DATA lv_total TYPE p DECIMALS 2.
lv_total = lv_price * 10 / 3.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_INLINE_PACKED

" SAP CI_ prefix format:
... "#EC CI_NO_INLINE_PACKED
```


## Related Rules

* [Prefer Calculation Assignment Operators (+=, -=, *=, /=)](/rules/pref-calc-op) — <code>#EC PREF_CALC_OP</code>
* [Prefer Inline Declarations over Separate DATA and Assignment](/rules/pref-inline) — <code>#EC PREF_INLINE</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_INLINE_PACKED`
* **ABAP Implementation:** [/skyl/cl_no_inline_packed.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_inline_packed.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 6039)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L6039)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_INLINE_PACKED&title=%5BBug%5D%3A%20Issue%20in%20no-inline-packed)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-inline-packed)**
