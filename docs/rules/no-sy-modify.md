---
title: "Avoid Direct Modification of System Fields (sy-*)"
description: "Preserve kernel state and execution integrity in SAP ABAP by eliminating direct assignments to system fields like sy-subrc and sy-tabix."
keywords: "no-sy-modify, sy-subrc, sy-tabix, Clean ABAP, ABAP system fields"
category: "security"
ruleId: "no-sy-modify"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1785"
---

# Avoid Direct Modification of System Fields (sy-*)

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Security & Robustness" />
  <Badge type="danger" text="#EC NO_SY_MODIFY" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1785" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid sy-* System Variable Modification.

> **ATC Finding Message:** `Avoid modifying system fields (sy-*); system variables are read-only`

## Rationale

System variables in the sy and syst structures (such as sy-subrc, sy-tabix, and sy-index) are maintained exclusively by the ABAP runtime kernel to reflect the execution state of system statements. Overwriting or clearing system fields manually in application code creates deceptive status values, masks technical failures from previous statements, corrupts debugger visibility, and induces unpredictable control flow across procedure boundaries. Code should communicate status through dedicated local variables, return parameters, or class-based exceptions.

### Non-Compliant

```abap
SELECT SINGLE partner
  FROM but000
  WHERE partner = @lv_partner_id
  INTO @DATA(lv_found_partner).
IF sy-subrc <> 0.
  " Anti-pattern: Overwrites kernel system field to mask missing partner
  sy-subrc = 0.
ENDIF.
```

### Compliant

```abap
SELECT SINGLE partner
  FROM but000
  WHERE partner = @lv_partner_id
  INTO @DATA(lv_found_partner).
DATA(lv_partner_exists) = xsdbool( sy-subrc = 0 ).
IF lv_partner_exists = abap_false.
  RETURN.
ENDIF.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_SY_MODIFY

" SAP CI_ prefix format:
... "#EC CI_NO_SY_MODIFY
```

### Detection Details

The rule scans compiler reference symbols for write access (`is_write_usage = abap_true`) to symbols in the `\DA:SY\*` or `\DA:SYST\*` namespace. Any assignment, `CLEAR`, `MOVE`, or calculation operation targeting a system field triggers finding code `NO_SY_MOD`.

Suppress false positives or intentional framework hooks using the pseudo-comment `"#EC NO_SY_MODIFY`.


## Related Rules

* [Prefer Short System Field Structure Alias SY Over Legacy SYST](/rules/pref-sy) — <code>#EC PREF_SY</code>
* [Replace Obsolete Arithmetic Statements with Modern Operators](/rules/no-obs-arith) — <code>#EC NO_OBS_ARITH</code>
* [Eliminate Obsolete Control Flow and Procedural Statements](/rules/no-obs-control) — <code>#EC NO_OBS_CONTROL</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_SY_MODIFY`
* **ABAP Implementation:** [/skyl/cl_no_sy_modify.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_sy_modify.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 1785)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L1785)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_SY_MODIFY&title=%5BBug%5D%3A%20Issue%20in%20no-sy-modify)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-sy-modify)**
