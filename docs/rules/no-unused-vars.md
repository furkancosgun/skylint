---
title: "Remove Unread Local Variables and Field Symbols"
description: "Detect and eliminate unread local variables and inline declarations in ABAP Cloud code according to Clean ABAP guidelines."
keywords: "no-unused-vars, Clean ABAP, ABAP Cloud, unused variables, dead code, SAP ATC"
category: "anti-patterns"
ruleId: "no-unused-vars"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2668"
---

# Remove Unread Local Variables and Field Symbols

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_UNUSED_VARS" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2668" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Detect unused local variables and field symbols.

> **ATC Finding Message:** `Local variable or field symbol is declared but never read`

## Rationale

Unused local variables and field symbols add cognitive clutter, create false assumptions during code reviews, and often signal incomplete refactorings or forgotten business calculations. In Clean ABAP and ABAP Cloud development, every declared variable must serve an active purpose in the routine; unread declarations waste memory and distract maintainers. The ATC check inspects symbol definitions from DATA and FIELD-SYMBOLS statements (including inline definitions) and emits NO_UNUS_VR if no subsequent READ reference exists.

### Non-Compliant

```abap
DATA lv_tax_rate TYPE decfloat34.
DATA lv_net_amount TYPE decfloat34.
lv_net_amount = calculate_net_amount( ).
process_invoice( iv_amount = lv_net_amount ).
```

### Compliant

```abap
DATA lv_net_amount TYPE decfloat34.
lv_net_amount = calculate_net_amount( ).
process_invoice( iv_amount = lv_net_amount ).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_UNUSED_VARS

" SAP CI_ prefix format:
... "#EC CI_NO_UNUSED_VARS
```

## Detection Details

The check collects all local definitions from `DATA`, `FIELD-SYMBOLS`, and inline declarations (`DATA(...)` and `FIELD-SYMBOL(...)`). It resolves compiler symbol references to verify whether each declared symbol is ever read within the procedure. If a variable is only written or never accessed, finding code `NO_UNUS_VR` is reported.

### Suppression
If a variable must be retained for signature or future contract compatibility, suppress the finding with `"#EC NO_UNUSED_VARS`.


## Related Rules

* [Enforce Configured Naming Conventions for Local Variables and Field-Symbols](/rules/pref-naming-vars) — <code>#EC PREF_NAMING_VARS</code>
* [Prevent Local Variables from Shadowing Class Attributes](/rules/no-shadow) — <code>#EC NO_SHADOW</code>
* [Declare Constants with an Explicit TYPE and LENGTH](/rules/pref-full-typed) — <code>#EC PREF_FULL_TYPED</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_UNUSED_VARS`
* **ABAP Implementation:** [/skyl/cl_no_unused_vars.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_unused_vars.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 2668)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L2668)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_UNUSED_VARS&title=%5BBug%5D%3A%20Issue%20in%20no-unused-vars)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-unused-vars)**
