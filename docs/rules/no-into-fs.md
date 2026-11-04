---
title: "Use ASSIGNING Instead of INTO with Field Symbols"
description: "Prevent dangerous INTO <fs> usage in ABAP READ TABLE and LOOP AT statements by enforcing ASSIGNING for field symbols."
keywords: "INTO field symbol, ASSIGNING <fs>, ABAP READ TABLE, Clean ABAP itab, SAP ATC check, no-into-fs"
category: "anti-patterns"
ruleId: "no-into-fs"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4915"
---

# Use ASSIGNING Instead of INTO with Field Symbols

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_INTO_FS" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4915" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Do not use INTO with a field symbol; use ASSIGNING instead.

> **ATC Finding Message:** `Do not use INTO with a field symbol; use ASSIGNING instead`

## Rationale

Using INTO `<fs>` in READ TABLE or LOOP AT statements performs value assignment into the memory currently dereferenced by the field symbol instead of binding the field symbol to the table row. If the field symbol is unassigned, it triggers a runtime crash (GETWA_NOT_ASSIGNED). If already assigned, it silently overwrites previously referenced memory while failing to provide reference semantics. Use ASSIGNING for pointer reference binding.

### Non-Compliant

```abap
READ TABLE lt_invoice_items INTO <ls_item> INDEX 1.
LOOP AT lt_invoice_items INTO <ls_item>.
  <ls_item>-tax_rate = '0.19'.
ENDLOOP.
```

### Compliant

```abap
READ TABLE lt_invoice_items ASSIGNING <ls_item> INDEX 1.
LOOP AT lt_invoice_items ASSIGNING <ls_item>.
  <ls_item>-tax_rate = '0.19'.
ENDLOOP.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_INTO_FS

" SAP CI_ prefix format:
... "#EC CI_NO_INTO_FS
```

### Semantics comparison

The difference between `INTO` and `ASSIGNING` with field symbols is fundamental:

| Syntax | Memory Semantics | Risk If Unassigned |
| --- | --- | --- |
| `READ TABLE itab INTO <fs>.` | Copy data into whatever `<fs>` currently points to | Runtime dump `GETWA_NOT_ASSIGNED` |
| `READ TABLE itab ASSIGNING <fs>.` | Bind `<fs>` to table row memory address | Safely handles `sy-subrc <> 0` |
| `LOOP AT itab INTO <fs>.` | Copy each row into target memory of `<fs>` | Runtime dump or stale target mutation |
| `LOOP AT itab ASSIGNING <fs>.` | Bind `<fs>` to each row in-place | Clean, zero-copy table iteration |

### Suppression

In the rare event that copying into a dynamically assigned buffer is deliberate, suppress with `"#EC NO_INTO_FS`.


## Related Rules

* [Escape ABAP SQL Host Variables and Table Targets with @](/rules/pref-strict-sql) — <code>#EC PREF_STRICT_SQL</code>
* [Make MODIFY, DELETE, INSERT and UPDATE Unambiguous for Itab and Database](/rules/no-ambiguous-stmt) — <code>#EC NO_AMBIGUOUS_STMT</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_INTO_FS`
* **ABAP Implementation:** [/skyl/cl_no_into_fs.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_into_fs.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4915)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4915)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_INTO_FS&title=%5BBug%5D%3A%20Issue%20in%20no-into-fs)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-into-fs)**
