---
title: "Compose Messages with String Templates Instead of CONCATENATE"
description: "Replace CONCATENATE and SEPARATED BY with |...| string templates or concat_lines_of for readable, Cloud-ready text composition."
keywords: "pref-str-tmpl, CONCATENATE, string template, concat_lines_of, ABAP Cloud"
category: "clean-abap"
ruleId: "pref-str-tmpl"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L682"
---

# Compose Messages with String Templates Instead of CONCATENATE

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_STR_TMPL" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L682" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Prefer string templates over CONCATENATE.

> **ATC Finding Message:** `Use string template |...| instead of CONCATENATE`

## Rationale

CONCATENATE needs a target variable and an optional SEPARATED BY addition, splits one message into a list of operands and cannot be nested in an expression. A string template keeps the text and the embedded values together, supports formatting options for dates, numbers and alignment, and composes directly inside method calls and constructor expressions. The check reports PREF_STMPL and the TOTEMPLATE quickfix rewrites the statement, including the CONCATENATE LINES OF variant which becomes concat_lines_of( ).

### Non-Compliant

```abap
CONCATENATE 'Order' lv_order_id 'was created on' lv_creation_date INTO lv_message SEPARATED BY space.
```

### Compliant

```abap
lv_message = |Order { lv_order_id } was created on { lv_creation_date }|.
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
... "#EC PREF_STR_TMPL

" SAP CI_ prefix format:
... "#EC CI_PREF_STR_TMPL
```

## Conversion Notes

- `CONCATENATE ... BYTE MODE` is ignored: binary concatenation has no string template equivalent.
- `CONCATENATE LINES OF itab INTO target [SEPARATED BY sep]` is rewritten to `concat_lines_of( table = itab [sep = sep] )`.
- All other statements become `target = |operand{ sep }operand|`; the `TOTEMPLATE` quickfix applies exactly that rewrite so the resulting statement stays valid ABAP.
- `CONCATENATE` is not released for ABAP Cloud, so migrating is also a Cloud-readiness requirement.


## Related Rules

* [Replace Obsolete String Statements with Built-in String Functions](/rules/pref-str-func) — <code>#EC PREF_STR_FUNC</code>
* [Fold Adjacent Static String Literals Concatenated with &&](/rules/no-useless-concat) — <code>#EC NO_USELESS_CONCAT</code>
* [Replace Obsolete String Statements and POSIX Regular Expressions](/rules/no-obs-strings) — <code>#EC NO_OBS_STRINGS</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_STR_TMPL`
* **ABAP Implementation:** [/skyl/cl_pref_str_tmpl.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_str_tmpl.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 682)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L682)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_STR_TMPL&title=%5BBug%5D%3A%20Issue%20in%20pref-str-tmpl)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-str-tmpl)**
