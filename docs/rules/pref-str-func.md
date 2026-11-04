---
title: "Replace Obsolete String Statements with Built-in String Functions"
description: "Replace CONDENSE, TRANSLATE, SHIFT, SEARCH, OVERLAY, REPLACE and DESCRIBE with modern built-in string functions such as to_upper( ) and shift_left( )."
keywords: "pref-str-func, string functions, CONDENSE, TRANSLATE, ABAP Cloud"
category: "clean-abap"
ruleId: "pref-str-func"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2570"
---

# Replace Obsolete String Statements with Built-in String Functions

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_STR_FUNC" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2570" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Detect obsolete string statements; prefer built-in functions.

> **ATC Finding Messages:**
> - `Use modern built-in string function condense( ... ) instead`
> - `Use modern string functions to_upper() or to_lower() instead`
> - `Use modern string function shift_left( ) or shift_right( ) instead`
> - `SEARCH statement is obsolete; prefer find( ) or contains( )`
> - `OVERLAY statement is obsolete; prefer string functions or templates`
> - `Obsolete REPLACE statement; prefer replace( ) function`
> - `Use strlen( ... ) instead of DESCRIBE FIELD ... LENGTH`

## Rationale

CONDENSE, TRANSLATE, SHIFT, SEARCH, OVERLAY, REPLACE and DESCRIBE FIELD mutate a variable in place, cannot be used inside an expression, and are flagged by the ABAP Cloud language profile. Built-in functions such as condense( ), to_upper( ), shift_left( ), find( ), replace( ) and strlen( ) return values, compose with constructor expressions and inline declarations, and state the intended transformation without side effects. The check reports one finding code per statement family and supplies QuickFixes for the mechanically safe rewrites.

### Non-Compliant

```abap
CONDENSE lv_address_text.
TRANSLATE lv_country_code TO UPPER CASE.
```

### Compliant

```abap
lv_address_text = condense( lv_address_text ).
lv_country_code  = to_upper( lv_country_code ).
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_CONDENSE` | `Boolean` | <code>true</code> | Report CONDENSE statements. The QuickFix rewrites them as condense( val = ... ) and keeps the NO-GAPS variant as from/to parameters. |
| `CHECK_TRANSLATE` | `Boolean` | <code>true</code> | Report TRANSLATE statements. UPPER and LOWER map to to_upper( ) / to_lower( ), while USING masks map to translate( ). |
| `CHECK_SHIFT` | `Boolean` | <code>true</code> | Report SHIFT statements. The QuickFix emits shift_left( ) or shift_right( ) with places or the DELETING mask. |
| `CHECK_SEARCH` | `Boolean` | <code>true</code> | Report SEARCH statements. No QuickFix is offered, because the correct replacement is find( ) or contains( ) depending on the surrounding logic. |
| `CHECK_OVERLAY` | `Boolean` | <code>true</code> | Report OVERLAY statements. No QuickFix is offered, because the replacement is a string template or an explicit replace( ). |
| `CHECK_REPLACE` | `Boolean` | <code>true</code> | Report REPLACE ... WITH ... INTO ... statements. The QuickFix rewrites them as replace( val = ... sub = ... with = ... ). |
| `CHECK_DESCRIBE` | `Boolean` | <code>true</code> | Report DESCRIBE FIELD ... LENGTH statements. The QuickFix writes strlen( ) or xstrlen( ) for the IN BYTE MODE variant. |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_STR_FUNC

" SAP CI_ prefix format:
... "#EC CI_PREF_STR_FUNC
```

### Finding codes

| Code | Obsolete statement | Replacement |
| --- | --- | --- |
| `PREF_CNDNS` | `CONDENSE` | `condense( )` |
| `PREF_TRNSL` | `TRANSLATE ... TO UPPER/LOWER CASE`, `USING` | `to_upper( )`, `to_lower( )`, `translate( )` |
| `PREF_SHIFT` | `SHIFT ... BY ... PLACES`, `DELETING LEADING/TRAILING` | `shift_left( )`, `shift_right( )` |
| `PREF_SRCH` | `SEARCH` | `find( )`, `contains( )` |
| `PREF_OVRLY` | `OVERLAY` | string templates, `replace( )` |
| `PREF_RPLC` | `REPLACE ... WITH ... INTO ...` | `replace( val = ... sub = ... with = ... )` |
| `PREF_DSCFD` | `DESCRIBE FIELD ... LENGTH` | `strlen( )`, `xstrlen( )` |

`SEARCH` and `OVERLAY` intentionally have no QuickFix. `REPLACE ... WITH ... IN ...` (in-place) and `DESCRIBE FIELD ... TYPE` are not reported by this check. All findings share the pseudo-comment `"#EC PREF_STR_FUNC`.


## Related Rules

* [Compose Messages with String Templates Instead of CONCATENATE](/rules/pref-str-tmpl) — <code>#EC PREF_STR_TMPL</code>
* [Fold Adjacent Static String Literals Concatenated with &&](/rules/no-useless-concat) — <code>#EC NO_USELESS_CONCAT</code>
* [Replace Obsolete String Statements and POSIX Regular Expressions](/rules/no-obs-strings) — <code>#EC NO_OBS_STRINGS</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_STR_FUNC`
* **ABAP Implementation:** [/skyl/cl_pref_str_func.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_str_func.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 2570)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L2570)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_STR_FUNC&title=%5BBug%5D%3A%20Issue%20in%20pref-str-func)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-str-func)**
