---
title: "Avoid Obsolete Inline Length Specifications (var(len))"
description: "Avoid Obsolete Inline Length Specifications (var(len)) - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, no-inline-len, anti-patterns"
---

# Avoid Obsolete Inline Length Specifications (var(len))

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_INLINE_LEN" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid inline length specification in declarations.

> **ATC Finding Message:** `Avoid length in parentheses; use TYPE ... LENGTH ...`

## Rationale

The legacy lv_name(10) syntax mixes the identifier and its length and is easy to misread as a substring or function call. Modern ABAP writes the type and length as separate, explicit tokens. Use TYPE c LENGTH n or a named type so the declaration is unambiguous.

### Non-Compliant

```abap
DATA lv_country(2) TYPE c.
```

### Compliant

```abap
DATA lv_country TYPE c LENGTH 2.
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
... "#EC NO_INLINE_LEN

" SAP CI_ prefix format:
... "#EC CI_NO_INLINE_LEN
```

## References & Standards

* [Official SAP Clean ABAP Style Guide](https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md)
* [SAP ABAP Keyword Documentation](https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/index.htm)

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_INLINE_LEN`
* **Implementation File:** [zcl_skylint_no_inline_len.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_inline_len.clas.abap)
