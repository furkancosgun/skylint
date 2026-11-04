---
title: "Prohibit Dynpro List Processing Statements in ABAP Cloud"
description: "Prohibit legacy dynpro list processing statements like WRITE, ULINE, and SKIP in ABAP Cloud."
keywords: "no-list-proc, WRITE statement, ULINE, list processing, Clean ABAP"
category: "anti-patterns"
ruleId: "no-list-proc"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1372"
---

# Prohibit Dynpro List Processing Statements in ABAP Cloud

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_LIST_PROC" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L1372" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Prohibit classic list processing statements.

> **ATC Finding Message:** `List processing statement is forbidden in OO/Cloud ABAP`

## Rationale

Classic dynpro list processing statements—including WRITE, ULINE, SKIP, FORMAT, and LEAVE LIST-PROCESSING—tightly couple business logic with archaic screen list buffers. These statements are fundamentally incompatible with ABAP Cloud (Language Version 5) and cannot function in background processing, headless REST APIs, or OData services. Application logic should format data through string templates and output messages via modern logging frameworks (such as cl_bali_log) or SAP Fiori / RAP consumption models.

### Non-Compliant

```abap
WRITE / 'Customer invoice processed successfully'.
ULINE.
SKIP 1.
```

### Compliant

```abap
mo_logger->add_info( 'Customer invoice processed successfully' ).
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_WRITE` | `Boolean` | <code>true</code> | Report classic list output WRITE statements that target dynpro list buffers. |
| `CHECK_ULINE` | `Boolean` | <code>true</code> | Report classic ULINE statements that output horizontal lines on screen lists. |
| `CHECK_SKIP` | `Boolean` | <code>true</code> | Report classic SKIP statements that insert blank lines into dynpro lists. |
| `CHECK_OTHER` | `Boolean` | <code>true</code> | Report formatting and list control statements like FORMAT, BACK, HIDE, and READ LINE. |
| `IGN_WRITE_TO` | `Boolean` | <code>true</code> | Ignore WRITE ... TO ... string formatting statements (prefer string templates instead). |
| `CHECK_LEAVE` | `Boolean` | <code>true</code> | Report LEAVE LIST-PROCESSING statements that exit dynpro screen list processing. |
| `CHECK_REJECT` | `Boolean` | <code>true</code> | Report obsolete REJECT statements used in classic logical database processing. |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_LIST_PROC

" SAP CI_ prefix format:
... "#EC CI_NO_LIST_PROC
```

### Prohibited List Processing Commands

- `WRITE` (excluding `WRITE ... TO ...` when `IGN_WRITE_TO` is enabled)
- `ULINE`, `SKIP`, `NEW-LINE`, `NEW-PAGE`
- `FORMAT`, `POSITION`, `RESERVE`, `BACK`, `HIDE`
- `READ LINE`, `MODIFY LINE`, `SCROLL LIST`
- `LEAVE LIST-PROCESSING`, `REJECT`

In modern ABAP Cloud, replace all classic list statements with structured application logging (`cl_bali_log`) or SAP Fiori UI services. Suppress findings with `"#EC NO_LIST_PROC`.


## Related Rules

* [Replace Obsolete Arithmetic Statements with Modern Operators](/rules/no-obs-arith) — <code>#EC NO_OBS_ARITH</code>
* [Eliminate Obsolete Control Flow and Procedural Statements](/rules/no-obs-control) — <code>#EC NO_OBS_CONTROL</code>
* [Replace Obsolete Data Declarations with Explicit Types](/rules/no-obs-decl) — <code>#EC NO_OBS_DECL</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_LIST_PROC`
* **ABAP Implementation:** [/skyl/cl_no_list_proc.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_list_proc.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 1372)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L1372)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_LIST_PROC&title=%5BBug%5D%3A%20Issue%20in%20no-list-proc)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-list-proc)**
