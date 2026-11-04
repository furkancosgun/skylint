---
title: "Detect 7.40+ Syntax in Downport-Compatible Code"
description: "Detect 7.40+ syntax such as table expressions, inline declarations, string templates and strict Open SQL when code must stay downport compatible."
keywords: "pref-downport, downport compatibility, 7.40 syntax, ABAP Cloud, SAP ATC"
category: "clean-abap"
ruleId: "pref-downport"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L198"
---

# Detect 7.40+ Syntax in Downport-Compatible Code

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_DOWNPORT" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L198" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Detect 7.40+ syntax incompatible with downport targets.

> **ATC Finding Message:** `Modern ABAP construct is incompatible with downport target release`

## Rationale

Table expressions, inline declarations, constructor expressions, string templates and strict Open SQL silently raise the kernel and syntax level required by a program, which breaks as soon as the code is transported to a 7.31 or early 7.40 system. The check exposes every such construct behind ten independent switches, each implemented as a concrete token pattern, and reports PREF_DWNPT for the first modern construct found in a statement. All switches default to false so modern ABAP Cloud development is never disturbed, and only a real downport target enables the ones it needs.

### Non-Compliant

```abap
DATA(lv_amount) = lt_open_items[ 1 ]-amount.
```

### Compliant

```abap
DATA lv_amount TYPE ty_open_item-amount.
DATA ls_open_item TYPE ty_open_item.
READ TABLE lt_open_items INTO ls_open_item INDEX 1.
IF sy-subrc = 0.
  lv_amount = ls_open_item-amount.
ENDIF.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_CONSTRUCTORS` | `Boolean` | <code>false</code> | Report constructor expressions (NEW, VALUE, COND, SWITCH, REDUCE, FILTER, CORRESPONDING, CONV, REF, CAST). Enable only for targets older than 7.40. |
| `CHECK_TABLE_EXPR` | `Boolean` | <code>false</code> | Report table expressions (itab[ ... ]). Enable for target releases below 7.40 SP08, where table expressions do not exist. |
| `CHECK_INLINE_DECL` | `Boolean` | <code>false</code> | Report inline declarations DATA(...), FINAL(...) and FIELD-SYMBOL(...). Enable when the downport target predates 7.40. |
| `CHECK_STRING_TEMPL` | `Boolean` | <code>false</code> | Report string templates (&#124;...&#124;) in any statement. Enable when the target kernel cannot compile templates. |
| `CHECK_CHAINING` | `Boolean` | <code>false</code> | Report functional method chaining such as lo_service->create( )->run( ). Enable when method chain expressions are unavailable. |
| `CHECK_EMPTY_KEY` | `Boolean` | <code>false</code> | Report WITH EMPTY KEY table definitions. Enable when the target release cannot declare an empty secondary key. |
| `CHECK_CALC_ASSIGN` | `Boolean` | <code>false</code> | Report calculation assignment operators +=, -=, *=, /= and &&=. Enable for releases before 7.40. |
| `CHECK_LINE_FUNCS` | `Boolean` | <code>false</code> | Report the LINE_EXISTS( ) and LINE_INDEX( ) built-ins. The lines( ) function is not evaluated, so enable this switch only when line functions are missing downport. |
| `CHECK_STRICT_SQL` | `Boolean` | <code>false</code> | Report @-escaped host expressions in Open SQL statements. Enable when only legacy Open SQL is supported by the target. |
| `CHECK_RAISE_MESSAGE` | `Boolean` | <code>false</code> | Report RAISE EXCEPTION ... MESSAGE ... additions. Enable when the target release lacks the MESSAGE addition. |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_DOWNPORT

" SAP CI_ prefix format:
... "#EC CI_PREF_DOWNPORT
```

## Configuration Switches

Every switch is a boolean and defaults to `abap_false`. Each statement is inspected in a fixed order and stops at the first matching check, so a statement that combines several modern constructs produces exactly one finding.

| Attribute | Modern construct detected |
|---|---|
| `CHECK_CONSTRUCTORS` | `NEW`, `VALUE`, `COND`, `SWITCH`, `REDUCE`, `FILTER`, `CORRESPONDING`, `EXACT`, `CONV`, `REF`, `CAST` followed by `(` |
| `CHECK_TABLE_EXPR` | Any `[` or `]` token, that is a table expression |
| `CHECK_INLINE_DECL` | `DATA(...)`, `FINAL(...)` and `FIELD-SYMBOL(...)` inline declarations |
| `CHECK_STRING_TEMPL` | Any token containing `|`, that is a string template |
| `CHECK_CHAINING` | Method calls whose tokens contain `)->` |
| `CHECK_EMPTY_KEY` | `WITH EMPTY KEY` |
| `CHECK_CALC_ASSIGN` | `+=`, `-=`, `*=`, `/=` and `&&=` |
| `CHECK_LINE_FUNCS` | `LINE_EXISTS(` and `LINE_INDEX(`; `lines(` is not evaluated by this switch |
| `CHECK_STRICT_SQL` | `@`-escaped host expressions in database statements |
| `CHECK_RAISE_MESSAGE` | `RAISE EXCEPTION ... MESSAGE ...` |

Enable only the switches that correspond to the oldest release you still support; mixing them all produces noise in code that is already downport-clean.


## Related Rules

* [Prefer Calculation Assignment Operators (+=, -=, *=, /=)](/rules/pref-calc-op) — <code>#EC PREF_CALC_OP</code>
* [Replace Textual Comparison Operators (EQ, NE, GT) with Symbols](/rules/pref-symbol-op) — <code>#EC PREF_SYMBOL_OP</code>
* [Prefer Short System Field Structure Alias SY Over Legacy SYST](/rules/pref-sy) — <code>#EC PREF_SY</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_DOWNPORT`
* **ABAP Implementation:** [/skyl/cl_pref_downport.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_downport.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 198)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L198)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_DOWNPORT&title=%5BBug%5D%3A%20Issue%20in%20pref-downport)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-downport)**
