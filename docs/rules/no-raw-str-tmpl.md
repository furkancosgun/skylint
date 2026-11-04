---
title: "Avoid String Templates Without Embedded Expressions"
description: "Detect unnecessary string templates in ABAP. Replace static |...| templates with standard string literals to optimize performance."
keywords: "String Template ABAP, Raw String Template, Clean ABAP Literals, ABAP String Performance"
category: "clean-abap"
ruleId: "no-raw-str-tmpl"
---

# Avoid String Templates Without Embedded Expressions

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC NO_RAW_STR_TMPL" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid string templates without embedded expressions.

> **ATC Finding Message:** `String template has no embedded expressions { }; use string literal or backticks`

## Rationale

Using string templates (`|...|`) without any embedded expressions `{ ... }` creates unnecessary string template runtime evaluation overhead and clutters code readability. If a string has no dynamic variables or formatting expressions, a standard single-quote literal (`'...'`) or backtick literal (``` `...` ```) should be used instead.

**Best Practice:** Only use `|...|` when interpolating expressions or formatting parameters.

### Non-Compliant

```abap
" Anti-pattern: String template with no dynamic expressions
DATA(lv_text) = |Hello World|.
DATA(lv_empty) = ||.
```

### Compliant

```abap
" Clean ABAP: Standard text literal or string backtick
DATA(lv_text) = 'Hello World'.
DATA(lv_str) = `Hello World`.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_EMPTY_TEMPLATE` | `Boolean` | <code>true</code> | Flag empty string templates (&#124;&#124;) |
| `CHECK_STATIC_TEMPLATE` | `Boolean` | <code>true</code> | Flag static string templates without expressions (&#124;text&#124;) |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_RAW_STR_TMPL

" SAP CI_ prefix format:
... "#EC CI_NO_RAW_STR_TMPL
```


## Related Rules

* [Prefer String Templates over CONCATENATE](/rules/pref-str-tmpl) — <code>#EC PREF_STR_TMPL</code>
* [Avoid Concatenating Adjacent String Literals](/rules/no-useless-concat) — <code>#EC NO_USELESS_CONCAT</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_RAW_STR_TMPL`
* **Implementation File:** [#skyl#cl_no_raw_str_tmpl.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_raw_str_tmpl.clas.abap)
