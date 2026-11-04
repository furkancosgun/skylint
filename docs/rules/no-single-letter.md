---
title: "Avoid Single-Letter Identifiers in Declarations"
description: "Single-letter ABAP variable names such as i, x or lv_i hurt code search and code review; enforce intention-revealing identifiers with this ATC check."
keywords: "ABAP variable naming, single letter variable, Clean ABAP naming, SAP ATC, no-single-letter"
category: "clean-abap"
ruleId: "no-single-letter"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4081"
---

# Avoid Single-Letter Identifiers in Declarations

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC NO_SINGLE_LETTER" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4081" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid single-letter variable names.

> **ATC Finding Message:** `Avoid single-letter variable names; use descriptive identifiers`

## Rationale

The variable name is the only documentation most call sites ever get, and a name like `i` or `lt_x` forces readers to scroll back to the declaration to learn what it holds. Searching for a single letter is hopeless because every `i` in the repository matches, which makes refactoring and code review slower. The check measures the last segment after the final underscore, so legacy names such as `lv_i` or `lt_x` are reported as well, while field symbols like `<fs>` and two-letter business words like `id` stay legal.

### Non-Compliant

```abap
DATA i TYPE i.
DATA lt_x TYPE string_table.
```

### Compliant

```abap
LOOP AT lt_pending_orders ASSIGNING FIELD-SYMBOL(<pending_order>).
  DATA(order_position) = sy-tabix.
ENDLOOP.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `MIN_NAME_LEN` | `Integer` | <code>2</code> | Minimum length of the last name segment; shorter names are reported (default 2, so only single-letter segments such as i, x or lv_i fail). |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_SINGLE_LETTER

" SAP CI_ prefix format:
... "#EC CI_NO_SINGLE_LETTER
```

### How the name length is measured

Only the **last** segment of the name (everything after the final underscore) is measured, and the `<` / `>` of field symbols are stripped first:

| Declaration | Measured segment | Length | Finding with `MIN_NAME_LEN = 2` |
| --- | --- | --- | --- |
| `DATA i TYPE i.` | `i` | 1 | yes (`NO_SGL_LTR`) |
| `DATA lv_i TYPE i.` | `i` | 1 | yes (`NO_SGL_LTR`) |
| `DATA lt_x TYPE string_table.` | `x` | 1 | yes (`NO_SGL_LTR`) |
| `FIELD-SYMBOLS <fs> TYPE string.` | `fs` | 2 | no |
| `DATA id TYPE sysuuid_x16.` | `id` | 2 | no |

Scanned statements are `DATA`, `CLASS-DATA`, `STATICS`, `FIELD-SYMBOLS` plus every inline declaration (`DATA(...)`, `FIELD-SYMBOL(...)`).

### Tuning

`MIN_NAME_LEN = 2` is the recommended setting: it kills the classic `i`, `j`, `x`, `y` loop indices without arguing about short but meaningful names. Raising it to `3` also rejects `id`, `no`, `ok` and is therefore a blunt instrument - prefer a review guideline over a high threshold.

Single-letter names that mirror an external API (for example a DDIC field copied verbatim) can be suppressed with `"#EC NO_SINGLE_LETTER` on the declaration.


## Related Rules

* [Declare Single-Assignment Local Variables with FINAL( )](/rules/pref-final-data) — <code>#EC PREF_FINAL_DATA</code>
* [Enforce Configured Naming Conventions for Local Variables and Field-Symbols](/rules/pref-naming-vars) — <code>#EC PREF_NAMING_VARS</code>
* [Prevent Variable Scope Leakage Outside Control Blocks](/rules/no-scope-leak) — <code>#EC NO_SCOPE_LEAK</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_SINGLE_LETTER`
* **ABAP Implementation:** [/skyl/cl_no_single_letter.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_single_letter.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4081)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4081)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_SINGLE_LETTER&title=%5BBug%5D%3A%20Issue%20in%20no-single-letter)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-single-letter)**
