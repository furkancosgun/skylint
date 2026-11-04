---
title: "Avoid BYPASSING BUFFER in ABAP SQL Queries"
description: "Prevent unnecessary database roundtrips by avoiding BYPASSING BUFFER on SAP table buffered entities in ABAP Cloud."
keywords: "no-bypass-buf, BYPASSING BUFFER, SAP table buffer, ABAP SQL performance, database caching"
category: "performance"
ruleId: "no-bypass-buf"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5703"
---

# Avoid BYPASSING BUFFER in ABAP SQL Queries

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Performance & Database" />
  <Badge type="danger" text="#EC NO_BYPASS_BUFFER" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5703" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid BYPASSING BUFFER in SELECT statements.

> **ATC Finding Message:** `Avoid BYPASSING BUFFER; leverage SAP table buffer for cached data access`

## Rationale

Specifying `BYPASSING BUFFER` in ABAP SQL forces an immediate direct roundtrip to the underlying database, explicitly circumventing the high-speed SAP table buffer on the application server. For customizing, configuration, and master data tables configured with single-record or generic buffering, bypassing the buffer creates redundant database network traffic, CPU overhead, and table locks. Relying on application server buffer synchronization preserves database capacity and yields sub-millisecond response times. The check reports `NO_BYP_BUF` to protect application server caching benefits.

### Non-Compliant

```abap
SELECT country_code, country_name
  FROM zcountry_config
  BYPASSING BUFFER
  WHERE country_code = @lv_country_code
  INTO @DATA(ls_country).
```

### Compliant

```abap
SELECT SINGLE country_code, country_name
  FROM zcountry_config
  WHERE country_code = @lv_country_code
  INTO @DATA(ls_country).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_BYPASS_BUFFER

" SAP CI_ prefix format:
... "#EC CI_NO_BYPASS_BUFFER
```

## Application Server Buffering Impact

| Buffer State | Execution Path | Latency Impact |
|---|---|---|
| Buffered (`SELECT`) | Read directly from Application Server shared memory | Microseconds (< 0.1 ms), zero DB CPU load |
| `BYPASSING BUFFER` | Network hop + Database optimizer planning + physical read | Milliseconds (1 - 10 ms), DB connection consumption |

### Valid Exceptions
- When reading immediately after an update in the same logical unit of work (LUW) before the database commit or buffer invalidation telegrams have propagated.
- Administrative buffer diagnosis utilities.
- Suppress necessary occurrences using `"#EC NO_BYPASS_BUFFER` or `##NO_BYPASS_BUFFER`.


## Related Rules

* [Avoid Unfiltered SELECT Statements on Database Tables](/rules/no-full-scan-sel) — <code>#EC NO_FULL_SCAN_SELECT</code>
* [Avoid SELECT * and Project Columns Explicitly](/rules/no-select-star) — <code>#EC NO_SELECT_STAR</code>
* [Replace READ TABLE with Table Expressions and line_exists](/rules/pref-read-table) — <code>#EC PREF_TAB_EXPR</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_BYPASS_BUF`
* **ABAP Implementation:** [/skyl/cl_no_bypass_buf.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_bypass_buf.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 5703)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L5703)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_BYPASS_BUF&title=%5BBug%5D%3A%20Issue%20in%20no-bypass-buf)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-bypass-buf)**
