---
title: "Avoid WITH DEFAULT KEY in Internal Table Declarations"
description: "Avoid WITH DEFAULT KEY declarations in internal tables and specify EMPTY KEY or explicit keys in Clean ABAP."
keywords: "no-default-key, WITH DEFAULT KEY, WITH EMPTY KEY, internal table key, Clean ABAP"
category: "anti-patterns"
ruleId: "no-default-key"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L416"
---

# Avoid WITH DEFAULT KEY in Internal Table Declarations

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_DEFAULT_KEY" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L416" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid WITH DEFAULT KEY; prefer EMPTY KEY or explicit keys.

> **ATC Finding Message:** `Avoid WITH DEFAULT KEY; specify EMPTY KEY or explicit key`

## Rationale

WITH DEFAULT KEY creates an implicit table key consisting of all non-numeric character fields in the line type. Adding or modifying fields in the underlying structure silently alters the table key, leading to unexpected duplicate handling in COLLECT or INSERT and unintended sort orders. In modern Clean ABAP and ABAP Cloud, internal tables must declare their key explicitly with WITH UNIQUE/NON-UNIQUE KEY or use WITH EMPTY KEY for index-accessed collections. The check flags DEFAULT KEY with finding NO_DEF_KEY and provides the USEEMPTY quickfix.

### Non-Compliant

```abap
DATA lt_sales_orders TYPE STANDARD TABLE OF ty_sales_order WITH DEFAULT KEY.
```

### Compliant

```abap
DATA lt_sales_orders TYPE STANDARD TABLE OF ty_sales_order WITH EMPTY KEY.
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_DEFAULT_KEY

" SAP CI_ prefix format:
... "#EC CI_NO_DEFAULT_KEY
```

### Key Semantics and Migration

In classic ABAP, `WITH DEFAULT KEY` included all text-like fields in the table key. This behavior often produces brittle code:

| Declaration | Key Behavior | Recommended Scenario |
|---|---|---|
| `WITH DEFAULT KEY` | Brittle implicit key over all non-numeric columns | Deprecated in Clean ABAP |
| `WITH EMPTY KEY` | No primary key; access strictly by index or iteration | Standard tables without key lookup requirements |
| `WITH UNIQUE / NON-UNIQUE KEY ...` | Explicit component list | Sorted, hashed, or keyed standard tables |

The `USEEMPTY` quickfix replaces `DEFAULT` with `EMPTY`. Statements can be suppressed using `"#EC NO_DEFAULT_KEY`.


## Related Rules

* [Declare Standard Internal Tables Explicitly with TYPE STANDARD TABLE OF](/rules/pref-std-table) — <code>#EC PREF_STD_TABLE</code>
* [Restrict Database Modifications to Customer-Owned Tables](/rules/no-mod-std-table) — <code>#EC NO_MOD_STD_TABLE</code>
* [Use lines( ) Instead of DESCRIBE TABLE LINES](/rules/pref-lines) — <code>#EC PREF_LINES</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_DEFAULT_KEY`
* **ABAP Implementation:** [/skyl/cl_no_default_key.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_default_key.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 416)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L416)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_DEFAULT_KEY&title=%5BBug%5D%3A%20Issue%20in%20no-default-key)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-default-key)**
