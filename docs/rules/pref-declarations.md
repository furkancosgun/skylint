---
title: "Routine Declaration Hygiene (Top Placement & Order)"
description: "Routine Declaration Hygiene (Top Placement & Order) - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-declarations, clean-abap"
category: "clean-abap"
ruleId: "pref-declarations"
---

# Routine Declaration Hygiene (Top Placement & Order)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC DEF_TOP" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Routine Declaration Hygiene (top placement & order).

> **ATC Finding Messages:**
> - `Reorder definitions to beginning of routine; avoid scattered declarations`
> - `Declare local TYPES before CONSTANTS before DATA before FIELD-SYMBOLS`

## Rationale

Declarations placed in the middle of executable code interrupt reading flow and conceal variable scope. Moreover, arbitrary ordering can place a DATA declaration before the TYPE it references. Maintain clean routine hygiene by placing all local declarations at the beginning of the routine in strict hierarchical order: TYPES before CONSTANTS before DATA before FIELD-SYMBOLS.

### Non-Compliant

```abap
METHOD process_order.
  lv_total = 100.
  DATA lv_tax TYPE i.
  FIELD-SYMBOLS <fs> TYPE i.
  TYPES ty_status TYPE c LENGTH 1.
ENDMETHOD.
```

### Compliant

```abap
METHOD process_order.
  TYPES ty_status TYPE c LENGTH 1.
  CONSTANTS lc_rate TYPE i VALUE 18.
  DATA lv_tax TYPE i.
  FIELD-SYMBOLS <fs> TYPE i.
  lv_total = 100.
ENDMETHOD.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_DEF_TOP` | `Boolean` | <code>true</code> | Enforce all local declarations (DATA, TYPES, CONSTANTS) at top of method body |
| `CHECK_DECL_ORDER` | `Boolean` | <code>true</code> | Enforce declaration order: TYPES first, then CONSTANTS, then DATA |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC DEF_TOP

" SAP CI_ prefix format:
... "#EC CI_DEF_TOP
```


## Related Rules

* [Prefer Modern Inline Declarations in ABAP 7.40+](/rules/pref-inline) — <code>#EC PREF_INLINE</code>
* [Prefer FINAL( ) over DATA( ) when the variable is never written again](/rules/pref-final-data) — <code>#EC PREF_FINAL_DATA</code>
* [Avoid Hungarian Notation and Type Prefixes](/rules/no-hungarian) — <code>#EC NO_HUNGARIAN</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_DECLARATIONS`
* **Implementation File:** [#skyl#cl_pref_declarations.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_declarations.clas.abap)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_DECLARATIONS&title=%5BBug%5D%3A%20Issue%20in%20pref-declarations)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-declarations)**
