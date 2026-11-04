---
title: "Replace Unexplained Magic Numbers with Named Constants"
description: "Replace unexplained magic numbers with typed named constants in ABAP Cloud and ATC checks."
keywords: "no-magic-numbers, magic numbers, named constants, Clean ABAP, SAP ATC"
category: "anti-patterns"
ruleId: "no-magic-numbers"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2132"
---

# Replace Unexplained Magic Numbers with Named Constants

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_MAGIC_NUMBERS" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L2132" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid magic numbers in code; use named constants.

> **ATC Finding Message:** `Avoid hardcoded magic numbers; declare a named constant`

## Rationale

Hardcoded numeric literals scattered across executable statements obscure the domain rationale and business rules underlying calculations or loop conditions. If the value needs to change, developers must perform error-prone global search-and-replace edits across programs. Clean ABAP mandates replacing magic numbers with typed, descriptive CONSTANTS declarations (such as c_max_retry_count or c_default_batch_size). This provides a single source of truth, documents business constraints, and ensures robust ABAP Cloud code quality.

### Non-Compliant

```abap
IF lv_retry_counter >= 5.
  terminate_processing( ).
ENDIF.
```

### Compliant

```abap
CONSTANTS c_max_retries TYPE i VALUE 5.
IF lv_retry_counter >= c_max_retries.
  terminate_processing( ).
ENDIF.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_MAGIC_NUMBERS

" SAP CI_ prefix format:
... "#EC CI_NO_MAGIC_NUMBERS
```

### Evaluated Statements and Exceptions

The rule inspects all executable statements outside of `CONSTANTS`, `DATA`, `TYPES`, and `STATICS` declarations:

- The numbers `0` and `1` are exempted as standard initializers and unit increments.
- Numeric exception return codes in `CALL FUNCTION ... EXCEPTIONS` clauses are exempted.
- Any other raw integer or decimal literal triggers finding code `NO_MAGIC_N`.

Suppress intentional magic numbers with `"#EC NO_MAGIC_NUMBERS`.


## Related Rules

* [Eliminate Unreachable Dead Code Caused by Constant False Conditions](/rules/no-dead-code) — <code>#EC NO_DEAD_CODE</code>
* [Avoid Unreachable Statements Following Unconditional Exit or Jump Operations](/rules/no-unreachable) — <code>#EC NO_UNREACHABLE</code>
* [Limit Method and Constructor Statement Length](/rules/max-method-len) — <code>#EC MAX_METHOD_LEN</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_MAGIC_NUMBERS`
* **ABAP Implementation:** [/skyl/cl_no_magic_numbers.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_magic_numbers.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 2132)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L2132)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_MAGIC_NUMBERS&title=%5BBug%5D%3A%20Issue%20in%20no-magic-numbers)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-magic-numbers)**
