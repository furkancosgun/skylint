---
title: "Use Appropriate Wildcards for LIKE and CP/NP Comparisons"
description: "Ensure correct wildcards in ABAP: enforce % and _ in SQL LIKE, and * and + in ABAP CP and NP comparisons."
keywords: "ABAP LIKE wildcard, CP operator ABAP, SQL wildcards, Clean ABAP, SAP ATC check, no-wrong-wildcard"
category: "anti-patterns"
ruleId: "no-wrong-wildcard"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4628"
---

# Use Appropriate Wildcards for LIKE and CP/NP Comparisons

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_WRONG_WILDCARD" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4628" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid wrong wildcards in LIKE, CP, and NP.

> **ATC Finding Messages:**
> - `Use % or _ as wildcards in LIKE comparisons instead of *`
> - `Use * or + as wildcards in CP and NP comparisons instead of %`

## Rationale

SQL pattern matching with LIKE uses standard SQL wildcards (% for multi-character sequences, _ for single characters), whereas ABAP logical comparisons with CP (Contains Pattern) and NP use ABAP wildcards (* and +). Interchanging them causes patterns to treat wildcards as literal characters, leading to silent query failures, unexpected empty result sets, or incorrect filtering logic in business workflows.

### Non-Compliant

```abap
SELECT SINGLE customer_id FROM zcustomers
  WHERE customer_id LIKE '*DE*'
  INTO @DATA(lv_customer).
IF lv_company_code CP 'US%'.
  apply_domestic_rules( ).
ENDIF.
```

### Compliant

```abap
SELECT SINGLE customer_id FROM zcustomers
  WHERE customer_id LIKE '%DE%'
  INTO @DATA(lv_customer).
IF lv_company_code CP 'US*'.
  apply_domestic_rules( ).
ENDIF.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_LIKE` | `Boolean` | <code>true</code> | Detect invalid wildcard usage such as asterisk (*) in SQL LIKE string comparisons (default true). |
| `CHECK_CP` | `Boolean` | <code>true</code> | Detect invalid wildcard usage such as percent (%) in ABAP CP and NP pattern comparisons (default true). |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_WRONG_WILDCARD

" SAP CI_ prefix format:
... "#EC CI_NO_WRONG_WILDCARD
```

### Wildcard conventions reference

ABAP distinguishes between Open SQL / ABAP SQL pattern syntax and internal ABAP character comparisons:

| Comparison Operator | Wildcard (Multi-char) | Wildcard (Single-char) | Finding on Misuse |
| --- | --- | --- | --- |
| `LIKE` (SQL / string) | `%` | `_` | `NO_LIKE_WL` when `*` is used |
| `CP` (Contains Pattern) | `*` | `+` | `NO_CP_WILD` when `%` is used |
| `NP` (No Pattern) | `*` | `+` | `NO_CP_WILD` when `%` is used |

### Suppression

When querying literal percent signs in CP (escaped via `#%`) or literal asterisks in LIKE, suppress with `"#EC NO_WRONG_WILDCARD`.


## Related Rules

* [Use BETWEEN for Inclusive Range Checks](/rules/pref-between) — <code>#EC PREF_BETWEEN</code>
* [Extract Repeated String Literals into Named Constants](/rules/no-dup-literals) — <code>#EC NO_DUP_LITERALS</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_WRONG_WILDCARD`
* **ABAP Implementation:** [/skyl/cl_no_wrong_wildcard.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_wrong_wildcard.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4628)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4628)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_WRONG_WILDCARD&title=%5BBug%5D%3A%20Issue%20in%20no-wrong-wildcard)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-wrong-wildcard)**
