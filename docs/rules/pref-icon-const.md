---
title: "Use ICON Constants Instead of Hardcoded @xx@ Icon Codes"
description: "Replace hardcoded @xx@ ABAP icon literals with readable icon_* constants from the ICON type pool and remove magic strings from ALV and UI code."
keywords: "ABAP icon constants, ICON type pool, @01@ icon code, SAP ATC, pref-icon-const"
category: "clean-abap"
ruleId: "pref-icon-const"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4690"
---

# Use ICON Constants Instead of Hardcoded @xx@ Icon Codes

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_ICON_CONST" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4690" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Prefer ICON_ constants over hardcoded icon codes.

> **ATC Finding Message:** `Use icon_ constants instead of hardcoded icon codes`

## Rationale

A literal such as `'@01@'` is an undocumented magic value: nobody can tell whether it means a green light, a printer or a warning, and the code silently shows the wrong glyph once the icon set or the UI technology changes. The icon type pool exposes readable constants - `icon_led_green`, `icon_cancel`, `icon_okay` - that name the glyph, can be searched and are documented in the system. The check flags every literal token of the icon-code shape inside a procedure, including literals used in `VALUE` additions and in `CONSTANTS`.

### Non-Compliant

```abap
DATA lv_status_icon TYPE c LENGTH 4.
lv_status_icon = '@01@'.
```

### Compliant

```abap
DATA lv_status_icon TYPE c LENGTH 4.
lv_status_icon = icon_led_green.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_ICON_CONST

" SAP CI_ prefix format:
... "#EC CI_PREF_ICON_CONST
```

### Detection logic

`PREF_ICON` is raised per token when the token is a literal of exactly six characters (quotes included) whose content matches `@++@`, that is a four-character icon code wrapped in `@`: `'@01@'`, `'@BZ@'`, `'@5B@'` or the backtick equivalents.

| Token | Reported |
| --- | --- |
| `'@01@'` | yes |
| `` `@5B@` `` | yes |
| `'OKAY'` | no - content does not match `@++@` |
| `'email@test.com'` | no - wrong length |
| longer ALV icon names that embed text (for example `'@01\QSystem\Q@'`) | no - the token is longer than six characters |
| `icon_led_green` | no - not a literal |

Both declaration positions (`DATA ... VALUE '@01@'`) and usage positions (`lv_icon = '@01@'`) are inspected, and a constant that stores the raw code is reported as well - point the constant at the icon constant instead.

### Which constant to use

Pick the constant that documents the glyph, not the one with the same number as in a screenshot: the mapping between `@nn@` codes and `icon_*` names differs between releases. The icon type pool (`SE11` type pool `ICON`, or report `RSCPICON`) lists the valid names for your system.

On ABAP Cloud, `TYPE-POOLS` is not available, so centralise the icons you need in a constants interface (for example `zif_ui_icons=>status_okay`) and reference that. The rule accepts any non-literal token, so such a constant is compliant. Suppress unavoidable raw codes from an external interface with `"#EC PREF_ICON_CONST`.


## Related Rules

* [Replace Unexplained Magic Numbers with Named Constants](/rules/no-magic-numbers) — <code>#EC NO_MAGIC_NUMBERS</code>
* [Extract Repeated String Literals into Named Constants](/rules/no-dup-literals) — <code>#EC NO_DUP_LITERALS</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_ICON_CONST`
* **ABAP Implementation:** [/skyl/cl_pref_icon_const.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_icon_const.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4690)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4690)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_ICON_CONST&title=%5BBug%5D%3A%20Issue%20in%20pref-icon-const)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-icon-const)**
