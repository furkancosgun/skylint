---
title: "Use Only Statements Available in ABAP Cloud"
description: "Detect ABAP statements that are not available in ABAP Cloud, including SUBMIT, CALL TRANSACTION, EXEC SQL and other legacy language elements."
keywords: "pref-cloud-ready, ABAP Cloud syntax, forbidden ABAP statements, Steampunk language subset, ABAP Cloud readiness, SAP ATC check"
category: "clean-abap"
ruleId: "pref-cloud-ready"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5926"
---

# Use Only Statements Available in ABAP Cloud

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_CLOUD_READY" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5926" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Statements not available in ABAP Cloud.

> **ATC Finding Message:** `Statement is not supported in ABAP Cloud; use modern syntax or a released API`

## Rationale

ABAP Cloud restricts development to a strictly released subset of language elements and APIs. Classic statements such as SUBMIT, CALL TRANSACTION, EXEC SQL, or legacy list processing are fundamentally unsupported in modern cloud environments (SAP BTP ABAP Environment and S/4HANA Cloud). Code containing these constructs cannot be compiled or transported to cloud systems. Replace non-cloud statements with released successor APIs, RAP business objects, or modern ABAP OO design patterns.

### Non-Compliant

```abap
" Classic report execution is not supported in ABAP Cloud
SUBMIT z_billing_report
  WITH p_vbeln = lv_billing_doc
  AND RETURN.
```

### Compliant

```abap
" Encapsulate logic into modern class methods or background jobs
zcl_billing_service=>process(
  iv_billing_doc = lv_billing_doc ).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_CLOUD_READY

" SAP CI_ prefix format:
... "#EC CI_PREF_CLOUD_READY
```

### Statement Scope and Handling

The check scans statement prefixes against the ABAP Cloud forbidden catalog:

| Statement Construct | Status | Note |
|---|---|---|
| `SUBMIT ...` | Forbidden | Classic report execution |
| `CALL TRANSACTION ...` | Forbidden | Dynpro transaction call |
| `EXEC SQL ...` | Forbidden | Native SQL |
| `CALL FUNCTION ...` | Allowed | Released function modules |
| `CREATE OBJECT ... TYPE ...` | Allowed | Standard ABAP OO instantiation |
| `SORT itab BY ...` | Allowed | Internal table sorting |

### Prefix Disambiguation

When a keyword prefix is shared between classic and cloud syntax, the longest match applies:
- `CALL` is forbidden, but `CALL FUNCTION` and `CALL METHOD` are allowed.
- `SORT` without an internal table is forbidden (dataset sort); `SORT itab` is allowed.
- `CREATE OBJECT` with `TYPE` is allowed; OLE automation (`CREATE OBJECT ref 'PROGID'`) is forbidden.
- Loop events (`AT NEW`, `AT LAST`) are allowed; dynpro events (`AT PF01`, `AT LINE-SELECTION`) are forbidden.

### Suppression

Suppress intentional legacy usages with `"#EC PREF_CLOUD_READY`.


## Related Rules

* [Eliminate Obsolete Control Flow and Procedural Statements](/rules/no-obs-control) — <code>#EC NO_OBS_CONTROL</code>
* [Prohibit Dynpro List Processing Statements in ABAP Cloud](/rules/no-list-proc) — <code>#EC NO_LIST_PROC</code>
* [Replace Obsolete Function Modules with Class-Based APIs](/rules/pref-func-module) — <code>#EC PREF_FUNC_MOD</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_CLOUD_READY`
* **ABAP Implementation:** [/skyl/cl_pref_cloud_ready.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_cloud_ready.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 5926)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L5926)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_CLOUD_READY&title=%5BBug%5D%3A%20Issue%20in%20pref-cloud-ready)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-cloud-ready)**
