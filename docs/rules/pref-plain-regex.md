---
title: "Prefer Simpler String Functions over Plain Regex"
description: "Prefer simpler string functions over plain regex in ABAP: replace metacharacter-free literal regex patterns with sub and case parameters. ABAP string processing performance and automated ATC inspection for SAP S/4HANA and ABAP Cloud."
keywords: "ABAP RegEx, Simple String Functions, find sub ABAP, Clean ABAP Strings, ATC Code Review"
category: "clean-abap"
ruleId: "pref-plain-regex"
---

# Prefer Simpler String Functions over Plain Regex

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_PLAIN_REGEX" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Prefer Simpler String Functions to Regex.

> **ATC Finding Message:** `Regex pattern contains no metacharacters - use the simple sub / case parameter instead`

## Rationale

A regex literal that contains no metacharacters (such as . [ { ( ) * + ? ^ $ | or the escape backslash) performs a plain literal search yet pays the regex engine's parsing and backtracking cost. Replace plain literal patterns with the simple, cheaper and more readable sub / case parameters of find, count, replace or contains. Only literal patterns without metacharacters are flagged; textual FIND/REPLACE with REGEX is covered by no-obs-strings.

### Non-Compliant

```abap
result = replace( val = text
  regex = 'HELLO'
  with = 'WORLD' ).
```

### Compliant

```abap
result = replace( val = text
  sub = 'HELLO'
  with = 'WORLD' ).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_PLAIN_REGEX

" SAP CI_ prefix format:
... "#EC CI_PREF_PLAIN_REGEX
```


## Related Rules

* [Avoid Obsolete String and POSIX Regex Statements](/rules/no-obs-strings) — <code>#EC NO_OBS_STRINGS</code>
* [Prefer Built-in String Functions over SEARCH/SHIFT](/rules/pref-str-func) — <code>#EC PREF_STR_FUNC</code>
* [Prefer String Templates over CONCATENATE](/rules/pref-str-tmpl) — <code>#EC PREF_STR_TMPL</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_PLAIN_REGEX`
* **Implementation File:** [#skyl#cl_pref_plain_regex.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_plain_regex.clas.abap)
