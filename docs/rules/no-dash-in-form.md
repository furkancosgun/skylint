---
title: "Use Underscores Instead of Hyphens in Subroutine FORM Names"
description: "Prevent hyphens in FORM routine names and convert dashes to underscores in ABAP code using automated ATC quickfixes."
keywords: "no-dash-in-form, Clean ABAP, FORM routine, subroutine naming, SAP ATC, quickfix"
category: "anti-patterns"
ruleId: "no-dash-in-form"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2785"
---

# Use Underscores Instead of Hyphens in Subroutine FORM Names

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_DASH_IN_FORM" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2785" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

No Dashes in Form Names.

> **ATC Finding Message:** `Avoid dashes in FORM names`

## Rationale

Using a hyphen inside a FORM subroutine name is an obsolete SAP syntax quirk that clashes with the structure component selector (-) in modern ABAP. It severely impairs readability, confuses static code analyzers, and introduces syntax ambiguity in legacy subroutines. Clean ABAP requires snake_case identifiers using underscores for all procedural names. The ATC check scans FORM statements for hyphens, reports NO_DASH_FM, and provides the DASH2UND quickfix to automatically replace hyphens with underscores.

### Non-Compliant

```abap
FORM calculate-tax-total.
ENDFORM.
```

### Compliant

```abap
FORM calculate_tax_total.
ENDFORM.
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
... "#EC NO_DASH_IN_FORM

" SAP CI_ prefix format:
... "#EC CI_NO_DASH_IN_FORM
```

## Detection Details

The rule checks statements with keyword `FORM` whose second token (subroutine name) contains a hyphen (`-`). The automated quickfix `DASH2UND` replaces every hyphen in the subroutine header with an underscore.

### Modern Alternative
While this rule ensures hygiene in legacy programs that still retain subroutines, new ABAP Cloud development prohibits `FORM` entirely. Subroutines should be refactored into methods on local or global classes.

### Suppression
Suppress findings with `"#EC NO_DASH_IN_FORM`.


## Related Rules

* [Replace Obsolete Arithmetic Statements with Modern Operators](/rules/no-obs-arith) — <code>#EC NO_OBS_ARITH</code>
* [Eliminate Obsolete Control Flow and Procedural Statements](/rules/no-obs-control) — <code>#EC NO_OBS_CONTROL</code>
* [Replace Obsolete Data Declarations with Explicit Types](/rules/no-obs-decl) — <code>#EC NO_OBS_DECL</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_DASH_IN_FORM`
* **ABAP Implementation:** [/skyl/cl_no_dash_in_form.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_dash_in_form.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 2785)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L2785)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_DASH_IN_FORM&title=%5BBug%5D%3A%20Issue%20in%20no-dash-in-form)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-dash-in-form)**
