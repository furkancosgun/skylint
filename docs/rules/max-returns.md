---
title: "Limit Number of Return Statements per Procedure"
description: "Limit RETURN statements in ABAP methods to maintain predictable exit points and clean procedural control flow in SAP ATC inspections."
keywords: "max-returns, multiple return statements, Clean ABAP control flow, guard clauses ABAP, SAP ATC metrics"
category: "metrics"
ruleId: "max-returns"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4176"
---

# Limit Number of Return Statements per Procedure

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Metrics & Complexity Limits" />
  <Badge type="danger" text="#EC MAX_RETURNS" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4176" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Limit number of RETURN statements (PLR0911).

> **ATC Finding Message:** `Method has too many RETURN statements; consider refactoring`

## Rationale

Scattering multiple RETURN statements across a large method implementation obscures control flow, complicates debugging, and makes verifying post-conditions or resource cleanup difficult. While Clean ABAP encourages early return guards at the beginning of a method to eliminate nested IF pyramids, having more than six exits in a single procedure indicates that the method handles too many responsibilities. Restructuring algorithms into lookup tables, conditional expressions, or specialized sub-methods keeps control flow predictable and maintainable in modern ABAP Cloud architectures.

### Non-Compliant

```abap
IF ls_shipment-is_cancelled = abap_true.
  rv_route = 'CANCELLED'.
  RETURN.
ENDIF.
IF ls_shipment-destination_country = 'DE'.
  rv_route = 'DOMESTIC_STANDARD'.
  RETURN.
ENDIF.
IF ls_shipment-destination_country = 'FR'.
  rv_route = 'WEST_EUROPE'.
  RETURN.
ENDIF.
IF ls_shipment-is_express = abap_true.
  rv_route = 'EXPRESS_AIR'.
  RETURN.
ENDIF.
IF ls_shipment-weight_kg > 1000.
  rv_route = 'HEAVY_FREIGHT'.
  RETURN.
ENDIF.
IF ls_shipment-has_hazmat = abap_true.
  rv_route = 'HAZMAT_SPECIAL'.
  RETURN.
ENDIF.
IF ls_shipment-is_customs_cleared = abap_false.
  rv_route = 'CUSTOMS_HOLD'.
  RETURN.
ENDIF.
rv_route = 'DEFAULT_ROUTING'.
```

### Compliant

```abap
IF ls_shipment-is_cancelled = abap_true.
  rv_route = 'CANCELLED'.
  RETURN.
ENDIF.

rv_route = COND string(
  WHEN ls_shipment-is_customs_cleared = abap_false THEN 'CUSTOMS_HOLD'
  WHEN ls_shipment-has_hazmat = abap_true          THEN 'HAZMAT_SPECIAL'
  WHEN ls_shipment-is_express = abap_true          THEN 'EXPRESS_AIR'
  WHEN ls_shipment-weight_kg > 1000                THEN 'HEAVY_FREIGHT'
  WHEN ls_shipment-destination_country = 'DE'      THEN 'DOMESTIC_STANDARD'
  WHEN ls_shipment-destination_country = 'FR'      THEN 'WEST_EUROPE'
  ELSE                                                  'DEFAULT_ROUTING' ).
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `MAX_RETURNS` | `Integer` | <code>6</code> | Maximum allowed RETURN statements within a single procedure body before triggering a refactoring warning (default: 6). |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC MAX_RETURNS

" SAP CI_ prefix format:
... "#EC CI_MAX_RETURNS
```

## Detection Scope

The check scans all statements in procedure implementations (methods, function modules, and form routines):

- **Keyword Matching**: Only statements with keyword `RETURN` are counted. `EXIT` and `CHECK` statements are not evaluated by this rule.
- **Reporting Target**: If the total number of `RETURN` statements exceeds `MAX_RETURNS` (default `6`), a finding with code `MAX_RET` is reported on the first statement of the procedure (e.g. `METHOD`).

## Suppression

Suppress the check using the pseudo-comment `"#EC MAX_RETURNS` placed on the opening procedure statement (e.g., `METHOD`).


## Related Rules

* [Limit Method Parameter Count and Keep One Parameter per Line](/rules/max-params) — <code>#EC MAX_PARAMS_COUNT</code>
* [Limit Method and Constructor Statement Length](/rules/max-method-len) — <code>#EC MAX_METHOD_LEN</code>
* [Limit One Statement per Source Code Line](/rules/max-one-stmt) — <code>#EC MAX_ONE_STMT</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_MAX_RETURNS`
* **ABAP Implementation:** [/skyl/cl_max_returns.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_max_returns.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4176)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4176)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_MAX_RETURNS&title=%5BBug%5D%3A%20Issue%20in%20max-returns)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20max-returns)**
