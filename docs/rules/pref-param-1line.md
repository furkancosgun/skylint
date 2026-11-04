---
title: "One Parameter or Structure Component per Line"
description: "Enforce one parameter or structure component assignment per line in ABAP method calls, VALUE and CORRESPONDING expressions for reviewable diffs."
keywords: "ABAP one parameter per line, VALUE constructor expression, method call formatting ABAP, SAP ATC, pref-param-1line"
category: "clean-abap"
ruleId: "pref-param-1line"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4888"
---

# One Parameter or Structure Component per Line

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_PARAM_1LINE" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4888" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Parameters and structure fields must be on separate lines.

> **ATC Finding Message:** `Multiple parameters or fields on the same line; place each on a separate line`

## Rationale

A call like `VALUE #( street = 'Main Street' city = 'Walldorf' )` packs several named parameters into one line, which makes a dropped entry invisible and turns the addition of one parameter into a reformat of the whole expression. One assignment per line gives every parameter its own diff line, keeps the call readable when a value is itself a constructor expression or a nested call, and stays within the 120-character limit. The check counts `=` signs inside parentheses per line, so it covers method calls, `VALUE`/`CORRESPONDING`/`NEW` expressions and nested calls alike.

### Non-Compliant

```abap
ls_address = VALUE #( street = 'Main Street' city = 'Walldorf' ).
```

### Compliant

```abap
ls_address = VALUE #(
    street = 'Main Street'
    city = 'Walldorf' ).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_PARAM_1LINE

" SAP CI_ prefix format:
... "#EC CI_PREF_PARAM_1LINE
```

### What triggers the finding

`PREF_1LINE` is raised on a statement when two `=` signs appear inside parentheses on the same source line, no matter whether they belong to a method call, a constructor expression or a nested call.

| Snippet | Result |
| --- | --- |
| `ls_address = VALUE #( street = 'Main Street' city = 'Walldorf' ).` | reported |
| `ls_address = VALUE #( street = 'Main Street'` + newline + `city = 'Walldorf' ).` | ok - different lines |
| `post_invoice( invoice = lo_invoice mode = 'I' ).` | reported |
| `post_invoice( invoice = lo_invoice` + newline + `mode = 'I' ).` | ok |
| `post_invoice( lo_invoice )` | ok - positional, no `=` |
| `IF lv_amount = lv_limit.` | ok - no parentheses |

One finding per statement is enough: fix the statement and re-run the check.

### Known edge case: parenthesised SQL

Because the heuristic only looks at `=` inside parentheses, a condition written on a single line inside a parenthesised ABAP SQL clause can be reported:

```abap
SELECT SINGLE * FROM zorder
  WHERE ( status = @lv_status AND created_by = @lv_user )
  INTO @DATA(ls_order).
```

Split the condition over several lines (as above) or suppress the statement with `"#EC PREF_PARAM_1LINE`. Positional arguments, `WHERE` clauses outside parentheses and comparisons in `IF` statements are never reported.


## Related Rules

* [Use Exactly One Space Between Tokens on the Same Line](/rules/no-double-space) — <code>#EC NO_DOUBLE_SPACE</code>
* [Limit Method and Constructor Statement Length](/rules/max-method-len) — <code>#EC MAX_METHOD_LEN</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_PARAM_1LINE`
* **ABAP Implementation:** [/skyl/cl_pref_param_1line.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_param_1line.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4888)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4888)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_PARAM_1LINE&title=%5BBug%5D%3A%20Issue%20in%20pref-param-1line)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-param-1line)**
