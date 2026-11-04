---
title: "Avoid Hungarian Notation and Legacy Type Prefixes in Names"
description: "Detect Hungarian notation in ABAP code - lv_, ls_, lt_, mv_, iv_, rv_ and fs_ prefixes - and enforce intention-revealing names in SAP ATC."
keywords: "Hungarian notation ABAP, lv_ ls_ prefix, ABAP variable naming, Clean ABAP, no-hungarian"
category: "clean-abap"
ruleId: "no-hungarian"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4143"
---

# Avoid Hungarian Notation and Legacy Type Prefixes in Names

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC NO_HUNGARIAN" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4143" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid Hungarian notation and encoding prefixes.

> **ATC Finding Message:** `Avoid Hungarian notation and encoding prefixes in names`

## Rationale

Prefixes such as `lv_`, `ls_`, `mt_` or `iv_` encode the technical type instead of the business meaning, and they go stale as soon as a variable becomes a field symbol or a structure is replaced by a class. They also bloat every call site and turn a type migration into a repository-wide rename. The check recognises the classic prefix families plus `fs_`, and it deliberately allows `is_*` names typed `abap_bool`, where the prefix reads as a predicate instead of a type hint.

### Non-Compliant

```abap
METHOD post_invoice.
  DATA lv_net_amount TYPE i.
  DATA lt_invoice_items TYPE STANDARD TABLE OF ty_invoice_item WITH EMPTY KEY.
ENDMETHOD.
```

### Compliant

```abap
METHOD post_invoice.
  DATA(net_amount) = calculate_net_amount( ).
  DATA(invoice_items) = read_open_items( ).
ENDMETHOD.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_ATTR` | `Boolean` | <code>true</code> | Report legacy prefixes on attributes declared with DATA, CLASS-DATA and CONSTANTS (default enabled). |
| `CHECK_LOCAL` | `Boolean` | <code>true</code> | Report legacy prefixes on local variables, STATICS and inline declarations (default enabled). |
| `CHECK_PARAM` | `Boolean` | <code>true</code> | Report legacy prefixes on method parameter names in METHODS and CLASS-METHODS signatures (default enabled). |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_HUNGARIAN

" SAP CI_ prefix format:
... "#EC CI_NO_HUNGARIAN
```

### Recognised prefix families

`NO_HUNGAR` is raised when the name matches `^[LMSGICER][VSTROCF]?_.*` or `^FS_.*`:

| Pattern | Typical origin | Examples |
| --- | --- | --- |
| `l*_...` | local | `lv_total`, `ls_header`, `lt_items`, `lo_service`, `lr_data`, `lc_limit`, `lf_callback` |
| `m*_...` | member | `mv_counter`, `ms_config`, `mt_rows`, `mo_adapter` |
| `g*_...` | global | `gv_instance`, `gt_buffer` |
| `s*_...` | static | `sv_cache`, `st_entries`, `so_where` |
| `i*_`, `e*_`, `r*_`, `c*_` | parameter kind | `iv_order_id`, `ev_result`, `rv_ok`, `cv_state` |
| `fs_...` | field symbol | `fs_row` |

### Exceptions and switches

- `is_*` names **typed `abap_bool`** are legal (`is_valid`, `is_locked`) because the prefix describes a predicate rather than a type. The same name typed as a structure is still reported.
- Inline declarations cannot see the declared type, so `DATA(is_valid) = abap_true.` is reported even though a typed `is_valid` attribute would pass. Name such booleans without the prefix or suppress the statement.
- `CHECK_ATTR`, `CHECK_LOCAL` and `CHECK_PARAM` let you stage the migration: keep `CHECK_PARAM` disabled while a published API is frozen, then switch it on for the next release.
- A single statement is reported at most once, and suppression works per statement with `"#EC NO_HUNGARIAN`.


## Related Rules

* [Enforce Standard Naming Conventions for Classes, Interfaces, Types and Global Objects](/rules/pref-name-objects) — <code>#EC PREF_NAME_OBJECTS</code>
* [Enforce Configured Naming Conventions for Local Variables and Field-Symbols](/rules/pref-naming-vars) — <code>#EC PREF_NAMING_VARS</code>
* [Enforce Standard Naming Conventions for Class Members, Parameters and Screens](/rules/pref-name-members) — <code>#EC PREF_NAME_MEMBERS</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_HUNGARIAN`
* **ABAP Implementation:** [/skyl/cl_no_hungarian.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_hungarian.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4143)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4143)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_HUNGARIAN&title=%5BBug%5D%3A%20Issue%20in%20no-hungarian)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-hungarian)**
