---
title: "Avoid Leading Wildcards in LIKE Conditions"
description: "Prevent full table scans by avoiding leading wildcards (% and +) in ABAP OpenSQL LIKE conditions."
keywords: "ABAP LIKE Wildcard, Leading Percent LIKE, Index Invalidation, SQL Performance"
category: "performance"
ruleId: "no-lead-wildcard"
---

# Avoid Leading Wildcards in LIKE Conditions

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="#EC NO_LEAD_WILDCARD" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid leading wildcard (% or +) in LIKE conditions.

> **ATC Finding Message:** `Avoid leading wildcard (% or +) in LIKE; prevents index usage causing full scan`

## Rationale

Using a leading wildcard (`%` or `+`) in a `LIKE` condition (e.g. `LIKE '%value'`) prevents the database optimizer from using B-tree and column indexes, resulting in full index scans or table scans.

**Standard:** Avoid leading wildcards in search patterns. If substring search is needed on large tables, consider SAP HANA full-text indexes or fuzzy search.

### Non-Compliant

```abap
" Leading wildcard prevents index utilization
SELECT * FROM t000 WHERE mandt LIKE '%00' INTO TABLE @DATA(lt_data).
```

### Compliant

```abap
" Prefix match utilizes index
SELECT * FROM t000 WHERE mandt LIKE '100%' INTO TABLE @DATA(lt_data).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_LEAD_WILDCARD

" SAP CI_ prefix format:
... "#EC CI_NO_LEAD_WILDCARD
```


## Related Rules

* [Avoid Unfiltered SELECT on Database Tables (Full Table Scan Prevention)](/rules/no-full-scan-sel) — <code>#EC NO_FULL_SCAN_SELECT</code>
* [Prefer BETWEEN for Inclusive Range Checks](/rules/pref-between) — <code>#EC PREF_BETWEEN</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_LEAD_WILDCARD`
* **Implementation File:** [#skyl#cl_no_lead_wildcard.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_lead_wildcard.clas.abap)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_LEAD_WILDCARD&title=%5BBug%5D%3A%20Issue%20in%20no-lead-wildcard)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-lead-wildcard)**
