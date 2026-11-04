---
title: "Avoid BYPASSING BUFFER in SELECT Statements"
description: "Prevent unnecessary database roundtrips in ABAP by avoiding BYPASSING BUFFER on buffered tables."
keywords: "ABAP Table Buffer, BYPASSING BUFFER, SAP Application Buffer, Performance Optimization"
category: "performance"
ruleId: "no-bypass-buf"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5510"
---

# Avoid BYPASSING BUFFER in SELECT Statements

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="#EC NO_BYPASS_BUFFER" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5510" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid BYPASSING BUFFER in SELECT statements.

> **ATC Finding Message:** `Avoid BYPASSING BUFFER; leverage SAP table buffer for cached data access`

## Rationale

Using `BYPASSING BUFFER` in ABAP SQL forces an expensive direct database roundtrip, explicitly ignoring the high-performance application server table buffer. For customizing and configuration tables, this creates unnecessary database load and eliminates the benefits of SAP table buffering.

**Standard:** Rely on SAP table buffering for cached tables unless an absolute real-time guarantee is strictly mandatory.

### Non-Compliant

```abap
" Bypasses application server buffer
SELECT * FROM t000 BYPASSING BUFFER INTO TABLE @DATA(lt_data).
```

### Compliant

```abap
" Uses SAP table buffer
SELECT * FROM t000 INTO TABLE @DATA(lt_data).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_BYPASS_BUFFER

" SAP CI_ prefix format:
... "#EC CI_NO_BYPASS_BUFFER
```


## Related Rules

* [Avoid Unfiltered SELECT on Database Tables (Full Table Scan Prevention)](/rules/no-full-scan-sel) — <code>#EC NO_FULL_SCAN_SELECT</code>
* [Avoid SELECT * in OpenSQL Queries (Minimize Memory & Network Overhead)](/rules/no-select-star) — <code>#EC NO_SELECT_STAR</code>
* [Modernize READ TABLE (Table Expressions & line_exists)](/rules/pref-read-table) — <code>#EC PREF_TAB_EXPR</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_BYPASS_BUF`
* **ABAP Implementation:** [/skyl/cl_no_bypass_buf.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_bypass_buf.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 5510)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L5510)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_BYPASS_BUF&title=%5BBug%5D%3A%20Issue%20in%20no-bypass-buf)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-bypass-buf)**
