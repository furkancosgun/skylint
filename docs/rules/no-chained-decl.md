---
title: "Avoid Chained Declarations for Variables, Types, and Constants"
description: "Avoid chained declarations (DATA:, TYPES:, CONSTANTS:) and use individual statements for clean git diffs in ABAP."
keywords: "no-chained-decl, chained declarations, DATA colon, Clean ABAP, SAP ATC"
category: "anti-patterns"
ruleId: "no-chained-decl"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L623"
---

# Avoid Chained Declarations for Variables, Types, and Constants

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_CHAINED_DECL" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L623" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid Chained Declarations.

> **ATC Finding Message:** `Avoid chained declarations; declare each entity individually`

## Rationale

Chained declarations (such as DATA:, TYPES:, and CONSTANTS:) combine multiple independent statements behind a single colon and commas, obscuring individual types and producing noisy git diffs when adding or modifying lines. Furthermore, chained declarations encourage upfront variable dumping at the start of a procedure rather than declaring variables close to first use. In Clean ABAP and ABAP Cloud, declare each variable or constant as an individual, fully qualified statement. The check reports NO_CHN_DCL and resolves the chain via the PREFINLDCL quickfix.

### Non-Compliant

```abap
DATA: lv_sales_order_id TYPE string,
      lv_delivery_block TYPE string.
```

### Compliant

```abap
DATA lv_sales_order_id TYPE string.
DATA lv_delivery_block TYPE string.
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `ALLOW_STRUCTURE_CHAINS` | `Boolean` | <code>true</code> | Allow chained statements exclusively for BEGIN OF ... END OF structure definitions. |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_CHAINED_DECL

" SAP CI_ prefix format:
... "#EC CI_NO_CHAINED_DECL
```

### Single Declarations vs. Structure Chains

Clean ABAP advocates individual statement declarations over colon-chained blocks:

```abap
" Anti-pattern: Chained declaration obscures diffs
DATA: lv_status TYPE bstat,
      lv_amount TYPE dmbtr.

" Recommended: Independent statements
DATA lv_status TYPE bstat.
DATA lv_amount TYPE dmbtr.
```

Structure definitions beginning with `BEGIN OF` are exempt when `ALLOW_STRUCTURE_CHAINS` is enabled (the default). The `PREFINLDCL` quickfix splits each chained entry into an independent statement prefixed by the appropriate declaration keyword. Suppress findings using `"#EC NO_CHAINED_DECL`.


## Related Rules

* [Avoid Chained Assignments Binding Multiple Targets Simultaneously](/rules/no-chained-assign) — <code>#EC NO_CHAINED_ASSIGN</code>
* [Prefer Inline Declarations over Separate DATA and Assignment](/rules/pref-inline) — <code>#EC PREF_INLINE</code>
* [Declare Single-Assignment Local Variables with FINAL( )](/rules/pref-final-data) — <code>#EC PREF_FINAL_DATA</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_CHAINED_DECL`
* **ABAP Implementation:** [/skyl/cl_no_chained_decl.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_chained_decl.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 623)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L623)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_CHAINED_DECL&title=%5BBug%5D%3A%20Issue%20in%20no-chained-decl)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-chained-decl)**
