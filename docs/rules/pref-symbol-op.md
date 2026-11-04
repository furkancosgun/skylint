---
title: "Replace Textual Comparison Operators (EQ, NE, GT) with Symbols"
description: "Replace legacy EQ, NE, GT, LT, GE and LE comparison keywords with the symbolic =, <>, >, <, >= and <= operators in ABAP Cloud and S/4HANA code."
keywords: "pref-symbol-op, Clean ABAP, comparison operators, SAP ATC, ABAP Cloud"
category: "clean-abap"
ruleId: "pref-symbol-op"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1004"
---

# Replace Textual Comparison Operators (EQ, NE, GT) with Symbols

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_SYMBOL_OP" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1004" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Prefer symbolic operators over textual EQ, NE, LT, GT.

> **ATC Finding Message:** `Prefer modern comparison operators (=, <>, <, >, <=, >=) over legacy keywords`

## Rationale

EQ, NE, GT, LT, GE and LE are legacy aliases for =, <>, >, <, >= and <=, and the check also catches the outdated => and =< spellings. Symbolic operators are shorter, follow mathematical notation, and are the only form Clean ABAP allows, so every condition in the code base reads the same way. The check inspects plain keyword tokens in executable statements, therefore the migration is mechanical and the PREFEROP QuickFix can rewrite the affected line without touching anything else.

### Non-Compliant

```abap
IF ls_order_header-total_amount GT ls_customer-credit_limit
   OR ls_order_header-payment_status NE 'PAID'.
  reject_sales_order( ).
ENDIF.
```

### Compliant

```abap
IF ls_order_header-total_amount > ls_customer-credit_limit
   OR ls_order_header-payment_status <> 'PAID'.
  reject_sales_order( ).
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
... "#EC PREF_SYMBOL_OP

" SAP CI_ prefix format:
... "#EC CI_PREF_SYMBOL_OP
```

### Replacement table

| Legacy | Symbol |
| --- | --- |
| `EQ` | `=` |
| `NE`, `><` | `<>` |
| `GT` | `>` |
| `LT` | `<` |
| `GE`, `=>` | `>=` |
| `LE`, `=<` | `<=` |

The check only inspects executable statements: `DATA`, `TYPES`, `CONSTANTS`, `STATICS`, `PARAMETER`, `PARAMETERS`, `FIELD-SYMBOLS`, `METHODS` and `CLASS-METHODS` are skipped so that a type or parameter that happens to be spelled `EQ` is never reported. Findings can be suppressed per statement with `"#EC PREF_SYMBOL_OP`; the `PREFEROP` QuickFix rewrites the whole line with the symbolic operator.


## Related Rules

* [Prefer Calculation Assignment Operators (+=, -=, *=, /=)](/rules/pref-calc-op) — <code>#EC PREF_CALC_OP</code>
* [Detect 7.40+ Syntax in Downport-Compatible Code](/rules/pref-downport) — <code>#EC PREF_DOWNPORT</code>
* [Prefer Short System Field Structure Alias SY Over Legacy SYST](/rules/pref-sy) — <code>#EC PREF_SY</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_SYMBOL_OP`
* **ABAP Implementation:** [/skyl/cl_pref_symbol_op.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_symbol_op.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 1004)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L1004)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_SYMBOL_OP&title=%5BBug%5D%3A%20Issue%20in%20pref-symbol-op)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-symbol-op)**
