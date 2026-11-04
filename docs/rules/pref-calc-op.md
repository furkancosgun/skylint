---
title: "Prefer Calculation Assignment Operators (+=, -=, *=, /=)"
description: "Use compound calculation assignment operators +=, -=, *= and /= instead of repeated self-assignments and obsolete ADD or SUBTRACT statements."
keywords: "pref-calc-op, calculation assignment, ADD SUBTRACT, Clean ABAP, SAP ATC"
category: "clean-abap"
ruleId: "pref-calc-op"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2607"
---

# Prefer Calculation Assignment Operators (+=, -=, *=, /=)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_CALC_OP" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2607" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Prefer calculation assignment operators (+=, -=, *=, /=).

> **ATC Finding Message:** `Use calculation assignment operator (+=, -=) or ADD statement replacement`

## Rationale

Assignments such as lv_stock = lv_stock - 1 repeat the target variable and force the reader to compare both sides to see that it is a simple update. Compound operators +=, -=, *= and /= express the change once, cannot accidentally read a different variable, and are the modern replacement for the obsolete ADD, SUBTRACT, MULTIPLY and DIVIDE statements. The check reports PREF_CALOP for both forms and supplies a CALCASGN QuickFix that rewrites the statement in place.

### Non-Compliant

```abap
lv_stock_quantity = lv_stock_quantity - 1.
```

### Compliant

```abap
lv_stock_quantity -= 1.
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
... "#EC PREF_CALC_OP

" SAP CI_ prefix format:
... "#EC CI_PREF_CALC_OP
```

### Rewrites

| Obsolete or verbose statement | Replacement |
| --- | --- |
| `ADD 1 TO lv_count.` | `lv_count += 1.` |
| `SUBTRACT 1 FROM lv_count.` | `lv_count -= 1.` |
| `MULTIPLY lv_count BY 2.` | `lv_count *= 2.` |
| `DIVIDE lv_count BY 2.` | `lv_count /= 2.` |
| `lv_count = lv_count + 1.` | `lv_count += 1.` |

The statement forms are only reported in the simple four-token shape; `ADD ... THEN`, `ACCORDING TO` and `PERFORM` variants are skipped. Self-assignments are recognised only when the left-hand side and the first operand are textually identical, so `lv_total = lv_total + lv_tax` is flagged while `lv_total = lv_subtotal + lv_tax` is not. Suppress with `"#EC PREF_CALC_OP`.


## Related Rules

* [Replace Textual Comparison Operators (EQ, NE, GT) with Symbols](/rules/pref-symbol-op) — <code>#EC PREF_SYMBOL_OP</code>
* [Replace Obsolete Arithmetic Statements with Modern Operators](/rules/no-obs-arith) — <code>#EC NO_OBS_ARITH</code>
* [Detect 7.40+ Syntax in Downport-Compatible Code](/rules/pref-downport) — <code>#EC PREF_DOWNPORT</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_CALC_OP`
* **ABAP Implementation:** [/skyl/cl_pref_calc_op.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_calc_op.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 2607)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L2607)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_CALC_OP&title=%5BBug%5D%3A%20Issue%20in%20pref-calc-op)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-calc-op)**
