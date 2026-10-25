---
description: "Obsolete String and Regex Statements"
---

# Avoid Obsolete String and POSIX Regex Statements

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC OBSOLETE_STR" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Obsolete String and Regex Statements.

> **ATC Finding Message:** `Avoid obsolete string statements (PACK, UNPACK, POSIX REGEX, etc.)`

## Rationale

Statements such as PACK, UNPACK, REPLACE ... INTO, and FIND/REPLACE with REGEX / OCCURENCES (along with POSIX regular expression classes like CL_ABAP_REGEX=>CREATE_POSIX) are legacy constructs superseded by modern PCRE (Perl-Compatible Regular Expressions via PCRE keywords / XCO regex) and standard string expressions / built-ins.

### Non-Compliant

```abap
PACK lv_source TO lv_packed.
FIND REGEX 'pattern' IN lv_text.
```

### Compliant

```abap
FIND PCRE 'pattern' IN lv_text.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value |
|---|---|:---:|
| `CHECK_PACK` | `Boolean` | <code>true</code> |
| `CHECK_UNPACK` | `Boolean` | <code>true</code> |
| `CHECK_REGEX` | `Boolean` | <code>true</code> |
| `CHECK_OCCURENCES` | `Boolean` | <code>true</code> |
| `CHECK_REPLACE_INTO` | `Boolean` | <code>true</code> |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC OBSOLETE_STR

" SAP CI_ prefix format:
... "#EC CI_OBSOLETE_STR
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_OBS_STRINGS`
* **Implementation File:** [zcl_skylint_no_obs_strings.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_obs_strings.clas.abap)
