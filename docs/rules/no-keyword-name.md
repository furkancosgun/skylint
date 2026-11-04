---
title: "Avoid Using ABAP Keywords as Identifier Names"
description: "Detect ABAP variables, constants, and field symbols whose names shadow ABAP language keywords, preventing syntax ambiguity and refactoring bugs."
keywords: "ABAP keyword shadowing, naming conventions, Clean ABAP, SAP ATC check, no-keyword-name"
category: "anti-patterns"
ruleId: "no-keyword-name"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3637"
---

# Avoid Using ABAP Keywords as Identifier Names

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_KEYWORD_NAME" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3637" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid Using ABAP Keywords as Identifier Names.

> **ATC Finding Message:** `Identifier name matches an ABAP keyword`

## Rationale

Declaring variables, field symbols, or constants with names that match ABAP language keywords (such as DATA, TYPE, CLASS, or MESSAGE) shadows built-in syntax terms. This causes semantic ambiguity in code reviews, breaks automated refactoring tools, and increases maintenance risk in ABAP Cloud where new language statements are regularly introduced. Identifiers should describe their business role rather than borrow language grammar keywords.

### Non-Compliant

```abap
DATA class TYPE string.
DATA(message) = 'Order approved'.
```

### Compliant

```abap
DATA lv_class_name TYPE string.
DATA(status_message) = 'Order approved'.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_KEYWORD_NAME

" SAP CI_ prefix format:
... "#EC CI_NO_KEYWORD_NAME
```

### What is reported

The check inspects explicit declaration statements (`DATA`, `CONSTANTS`, `STATICS`, `TYPES`, `FIELD-SYMBOLS`) as well as modern inline declarations (`DATA(...)`, `FIELD-SYMBOL(...)`). If the declared identifier matches an ABAP reserved keyword, finding `NO_KWD_NAM` is raised.

| Declaration | Finding | Recommended alternative |
| --- | --- | --- |
| `DATA class TYPE string.` | yes (`NO_KWD_NAM`) | `DATA class_name TYPE string.` |
| `DATA(message) = 'Success'.` | yes (`NO_KWD_NAM`) | `DATA(log_message) = 'Success'.` |
| `FIELD-SYMBOLS <table\> TYPE any table.` | yes (`NO_KWD_NAM`) | `FIELD-SYMBOLS <partner_table\> TYPE any table.` |
| `DATA lv_class_name TYPE string.` | no | - |

### Suppression

Legitimate mappings to legacy APIs or external data structures can be suppressed using pseudo-comment `"#EC NO_KEYWORD_NAME` on the declaration statement.


## Related Rules

* [Enforce Standard Naming Conventions for Class Members, Parameters and Screens](/rules/pref-name-members) — <code>#EC PREF_NAME_MEMBERS</code>
* [Enforce Standard Naming Conventions for Classes, Interfaces, Types and Global Objects](/rules/pref-name-objects) — <code>#EC PREF_NAME_OBJECTS</code>
* [Use Predicate Naming (is_, has_, can_) for Boolean Methods](/rules/pref-pred-name) — <code>#EC PREF_PRED_NAME</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_KEYWORD_NAME`
* **ABAP Implementation:** [/skyl/cl_no_keyword_name.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_keyword_name.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3637)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3637)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_KEYWORD_NAME&title=%5BBug%5D%3A%20Issue%20in%20no-keyword-name)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-keyword-name)**
