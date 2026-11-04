---
title: "Avoid INTO with Field Symbols"
description: "Prevent accidental INTO dereferencing with field symbols in internal table reads and loops."
keywords: "Clean ABAP, into field symbol, no-into-fs"
category: "anti-patterns"
ruleId: "no-into-fs"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4775"
---

# Avoid INTO with Field Symbols

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_INTO_FS" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4775" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Do not use INTO with a field symbol; use ASSIGNING instead.

> **ATC Finding Message:** `Do not use INTO with a field symbol; use ASSIGNING instead`

## Rationale

Using INTO with a field symbol in READ TABLE or LOOP AT causes value assignment rather than pointer binding, which is almost always an accidental bug. Use ASSIGNING instead.

### Non-Compliant

```abap
READ TABLE lt_data INTO <fs_row> INDEX 1.
```

### Compliant

```abap
READ TABLE lt_data ASSIGNING <fs_row> INDEX 1.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_INTO_FS

" SAP CI_ prefix format:
... "#EC CI_NO_INTO_FS
```


## Related Rules

* [Prefer Strict SQL Host Variable Escaping](/rules/pref-strict-sql) — <code>#EC PREF_STRICT_SQL</code>
* [Avoid Ambiguous Statements](/rules/no-ambiguous-stmt) — <code>#EC NO_AMBIGUOUS_STMT</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_INTO_FS`
* **ABAP Implementation:** [/skyl/cl_no_into_fs.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_into_fs.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4775)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4775)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_INTO_FS&title=%5BBug%5D%3A%20Issue%20in%20no-into-fs)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-into-fs)**
