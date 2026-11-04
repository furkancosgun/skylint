---
title: "Use Simple String Functions Instead of Metacharacter-Free Regex"
description: "Replace metacharacter-free regex patterns in ABAP find, replace and count with the sub parameter - avoid regex engine overhead for literal searches."
keywords: "ABAP regex, find sub parameter, pref-plain-regex, string function performance, Clean ABAP"
category: "clean-abap"
ruleId: "pref-plain-regex"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5351"
---

# Use Simple String Functions Instead of Metacharacter-Free Regex

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_PLAIN_REGEX" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L5351" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Prefer Simpler String Functions to Regex.

> **ATC Finding Message:** `Regex pattern contains no metacharacters - use the simple sub / case parameter instead`

## Rationale

When a regex pattern contains no metacharacter, the regex engine still compiles the pattern, builds its internal automaton and runs the backtracking machinery for a task that a plain substring comparison answers directly. The simple parameters sub, case, start and occurrence are cheaper, immune to escaping mistakes and obvious to reviewers, which matters in hot paths such as log parsing or mass data cleansing. The check reports PREF_PREGX only for literal, non-template patterns that contain none of the metacharacters . [ { ( ) * + ? ^ $ | \, so genuine regular expressions and dynamically built patterns stay untouched. Textual FIND/REPLACE with REGEX is a separate concern handled by no-obs-strings.

### Non-Compliant

```abap
DATA(lv_clean) = replace( val = lv_comment regex = 'TODO' with = 'DONE' ).
```

### Compliant

```abap
DATA(lv_clean) = replace( val = lv_comment sub = 'TODO' with = 'DONE' ).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_PLAIN_REGEX

" SAP CI_ prefix format:
... "#EC CI_PREF_PLAIN_REGEX
```

## Metacharacters that disable the finding

`. [ { ( ) * + ? ^ $ | \`

Any pattern containing one of these characters is treated as a real regular expression and is not reported.

## Not reported

| Case | Reason |
| --- | --- |
| `regex = lv_pattern` | pattern is only known at runtime |
| `regex = |HELLO|` | string template may embed an expression |
| `regex = ''` | empty pattern, rejected by the length guard |
| `find( val = lv_text sub = 'HELLO' )` | no `REGEX` token |

## Replacements

| Reported | Replacement |
| --- | --- |
| `find( val = lv_text regex = 'TODO' )` | `find( val = lv_text sub = 'TODO' )` |
| `replace( val = lv_text regex = 'TODO' with = 'DONE' )` | `replace( val = lv_text sub = 'TODO' with = 'DONE' )` |
| `count( val = lv_text regex = 'TODO' )` | `count( val = lv_text sub = 'TODO' )` |
| `contains( val = lv_text regex = 'TODO' )` | `contains( val = lv_text sub = 'TODO' )` |

Add `case = abap_true` or `case = abap_false` explicitly when the replacement must keep the exact case sensitivity of the original pattern.

Pseudo-comment: `"#EC PREF_PLAIN_REGEX`.


## Related Rules

* [Replace Obsolete String Statements and POSIX Regular Expressions](/rules/no-obs-strings) — <code>#EC NO_OBS_STRINGS</code>
* [Replace Obsolete String Statements with Built-in String Functions](/rules/pref-str-func) — <code>#EC PREF_STR_FUNC</code>
* [Compose Messages with String Templates Instead of CONCATENATE](/rules/pref-str-tmpl) — <code>#EC PREF_STR_TMPL</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_PLAIN_REGEX`
* **ABAP Implementation:** [/skyl/cl_pref_plain_regex.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_plain_regex.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 5351)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L5351)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_PLAIN_REGEX&title=%5BBug%5D%3A%20Issue%20in%20pref-plain-regex)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-plain-regex)**
