---
title: "Avoid Wrong Wildcards in LIKE, CP, and NP"
description: "Avoid wrong wildcards in ABAP LIKE, CP, and NP comparisons: ensure % is used in SQL LIKE and * is used in CP/NP."
keywords: "ABAP LIKE wildcard, ABAP CP wildcard, wrong wildcard ABAP, Clean ABAP LIKE CP, SAP ATC check wildcard"
category: "anti-patterns"
ruleId: "no-wrong-wildcard"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4514"
---

# Avoid Wrong Wildcards in LIKE, CP, and NP

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_WRONG_WILDCARD" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4514" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid wrong wildcards in LIKE, CP, and NP.

> **ATC Finding Messages:**
> - `Use % or _ as wildcards in LIKE comparisons instead of *`
> - `Use * or + as wildcards in CP and NP comparisons instead of %`

## Rationale

ABAP SQL LIKE statements use '%' (matching any sequence of characters) and '_' (matching a single character) as wildcards. In contrast, ABAP logical comparison operators CP and NP use '*' and '+' as wildcards. Using '*' in LIKE or '%' in CP/NP indicates confusion between SQL pattern matching and ABAP string matching.

### Non-Compliant

```abap
SELECT SINGLE carrid FROM scarr WHERE carrid LIKE '*LH*' INTO @lv_text.
IF lv_text CP 'prefix%'.
  RETURN.
ENDIF.
```

### Compliant

```abap
SELECT SINGLE carrid FROM scarr WHERE carrid LIKE '%LH%' INTO @lv_text.
IF lv_text CP 'prefix*'.
  RETURN.
ENDIF.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_LIKE` | `Boolean` | <code>true</code> | Enable checking for invalid wildcard usage in LIKE comparisons (defaults to true) |
| `CHECK_CP` | `Boolean` | <code>true</code> | Enable checking for invalid wildcard usage in CP and NP comparisons (defaults to true) |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_WRONG_WILDCARD

" SAP CI_ prefix format:
... "#EC CI_NO_WRONG_WILDCARD
```


## Related Rules

* [Prefer BETWEEN for Inclusive Range Checks](/rules/pref-between) — <code>#EC PREF_BETWEEN</code>
* [Avoid Repeating the Same String Literal](/rules/no-dup-literals) — <code>#EC NO_DUP_LITERALS</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_WRONG_WILDCARD`
* **ABAP Implementation:** [/skyl/cl_no_wrong_wildcard.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_wrong_wildcard.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4514)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4514)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_WRONG_WILDCARD&title=%5BBug%5D%3A%20Issue%20in%20no-wrong-wildcard)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-wrong-wildcard)**
