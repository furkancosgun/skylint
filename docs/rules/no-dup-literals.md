---
title: "Avoid Repeating the Same String Literal"
description: "Avoid Repeating the Same String Literal - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-dup-literals, anti-patterns"
category: "anti-patterns"
ruleId: "no-dup-literals"
---

# Avoid Repeating the Same String Literal

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_DUP_LITERALS" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid repeating the same string literal.

> **ATC Finding Message:** `Replace repeated literals with a constant`

## Rationale

Repeating the same string literal in several places couples unrelated code to an unnamed value and makes a later change error-prone. Define a constant with a meaningful name and reuse it. The check focuses on fixed string literals that occur at least three times.

### Non-Compliant

```abap
IF lv_status = 'ACTIVE'.
  lv_text = 'ACTIVE'.
ENDIF.
```

### Compliant

```abap
CONSTANTS c_active TYPE string VALUE 'ACTIVE'.
IF lv_status = c_active.
  lv_text = c_active.
ENDIF.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `MIN_OCCURRENCES` | `Integer` | <code>3</code> | Minimum occurrences of identical string literal before reporting (default: 3) |
| `MIN_LENGTH` | `Integer` | <code>3</code> | Minimum character length of string literal to inspect (default: 3) |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_DUP_LITERALS

" SAP CI_ prefix format:
... "#EC CI_NO_DUP_LITERALS
```


## Related Rules

* [Avoid Concatenating Adjacent String Literals](/rules/no-useless-concat) — <code>#EC NO_USELESS_CONCAT</code>
* [Avoid Obsolete String and POSIX Regex Statements](/rules/no-obs-strings) — <code>#EC NO_OBS_STRINGS</code>
* [Prefer String Templates over CONCATENATE](/rules/pref-str-tmpl) — <code>#EC PREF_STR_TMPL</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_DUP_LITERALS`
* **Implementation File:** [zcl_skylint_no_dup_literals.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_dup_literals.clas.abap)
