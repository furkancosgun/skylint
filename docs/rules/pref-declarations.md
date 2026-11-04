---
title: "Enforce Routine Declaration Hierarchy and Top-of-Block Placement"
description: "Enforce clean ABAP routine declaration hygiene by placing TYPES, CONSTANTS, DATA, and FIELD-SYMBOLS at the top in structured hierarchy."
keywords: "pref-declarations, declaration order, local variables, Clean ABAP, SAP ATC"
category: "clean-abap"
ruleId: "pref-declarations"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3137"
---

# Enforce Routine Declaration Hierarchy and Top-of-Block Placement

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC DEF_TOP" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3137" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Routine Declaration Hygiene (top placement & order).

> **ATC Finding Messages:**
> - `Reorder definitions to beginning of routine; avoid scattered declarations`
> - `Declare local TYPES before CONSTANTS before DATA before FIELD-SYMBOLS`

## Rationale

Interleaving data declarations with executable statements obscures variable scope and hampers readability during routine maintenance. Furthermore, declaring variables before the custom types they reference causes cognitive friction and compilation anomalies. Maintaining strict routine declaration hygiene requires placing all local declarations at the beginning of the routine in hierarchical order: TYPES first, followed by CONSTANTS, DATA or STATICS, and finally FIELD-SYMBOLS. Skylint flags scattered declarations with PREF_TOP and out-of-order declarations with PREF_ORDER.

### Non-Compliant

```abap
METHOD run.
  DATA lv_total_amount TYPE i.
  lv_total_amount = 100.
  DATA lv_tax_amount TYPE i.
  FIELD-SYMBOLS <ls_item> TYPE any.
  TYPES ty_status TYPE c LENGTH 1.
ENDMETHOD.
```

### Compliant

```abap
METHOD run.
  TYPES ty_status TYPE c LENGTH 1.
  CONSTANTS lc_standard_rate TYPE i VALUE 18.
  DATA lv_total_amount TYPE i.
  DATA lv_tax_amount TYPE i.
  FIELD-SYMBOLS <ls_item> TYPE any.
  lv_total_amount = 100.
ENDMETHOD.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_DEF_TOP` | `Boolean` | <code>true</code> | Enforce all local declarations (DATA, TYPES, CONSTANTS, FIELD-SYMBOLS) at the top of the routine body. |
| `CHECK_DECL_ORDER` | `Boolean` | <code>true</code> | Enforce declaration order: TYPES first, then CONSTANTS, then DATA/STATICS, then FIELD-SYMBOLS. |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC DEF_TOP

" SAP CI_ prefix format:
... "#EC CI_DEF_TOP
```

## Enforced Declaration Hierarchy

When `CHECK_DECL_ORDER` is enabled, all declarations preceding the first executable statement must respect the following rank order:

1. `TYPES` (rank 1)
2. `CONSTANTS` (rank 2)
3. `DATA` / `STATICS` (rank 3)
4. `FIELD-SYMBOLS` (rank 4)

Any declaration occurring after an executable statement triggers `PREF_TOP` when `CHECK_DEF_TOP` is active.

Suppress findings with pseudo comments `"#EC PREF_DEFINITIONS_TOP` / `"#EC PREF_DECLARATION_ORDER`.


## Related Rules

* [Prefer Inline Declarations over Separate DATA and Assignment](/rules/pref-inline) — <code>#EC PREF_INLINE</code>
* [Declare Single-Assignment Local Variables with FINAL( )](/rules/pref-final-data) — <code>#EC PREF_FINAL_DATA</code>
* [Avoid Hungarian Notation and Legacy Type Prefixes in Names](/rules/no-hungarian) — <code>#EC NO_HUNGARIAN</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_DECLARATIONS`
* **ABAP Implementation:** [/skyl/cl_pref_declarations.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_declarations.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3137)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3137)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_DECLARATIONS&title=%5BBug%5D%3A%20Issue%20in%20pref-declarations)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-declarations)**
