---
title: "Eliminate Unreachable Dead Code Caused by Constant False Conditions"
description: "Detect and delete unreachable dead code branches caused by constant false conditions in ABAP using ATC quickfixes."
keywords: "no-dead-code, Clean ABAP, ABAP Cloud, dead code, constant conditions, SAP ATC"
category: "anti-patterns"
ruleId: "no-dead-code"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3608"
---

# Eliminate Unreachable Dead Code Caused by Constant False Conditions

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_DEAD_CODE" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3608" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Detect Dead Code with Constant Condition.

> **ATC Finding Message:** `Condition is always false, creating dead code`

## Rationale

Conditions that evaluate to constant false at compile time, such as IF 1 = 2, CHECK abap_false, or impossible BETWEEN ranges, create unreachable dead code branches that clutter the codebase and confuse maintainers. Dead branches often harbor obsolete or unmaintained logic, deceive reviewers during audits, and prevent accurate test coverage calculations. Clean ABAP mandates removing dead conditional branches or replacing constant flags with valid runtime business conditions. The ATC check emits NO_DEAD_CD and provides the DELDEAD quickfix.

### Non-Compliant

```abap
IF 1 = 2.
  archive_obsolete_invoices( ).
ENDIF.
```

### Compliant

```abap
IF lv_is_archiving_enabled = abap_true.
  archive_obsolete_invoices( ).
ENDIF.
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
... "#EC NO_DEAD_CODE

" SAP CI_ prefix format:
... "#EC CI_NO_DEAD_CODE
```

## Evaluated Constant Patterns

The check statically evaluates conditional expressions in `IF`, `ELSEIF`, `WHILE`, and `CHECK` statements:
- **Boolean constants**: `IF abap_false.` or `CHECK abap_false.`
- **Numeric comparisons**: Comparisons between literals such as `1 = 2`, `-5 > +3`, or `10 < 2`
- **Literal string comparisons**: Incompatible string literals such as `'A' = 'B'`
- **Constant BETWEEN ranges**: Ranges where the operand falls outside the boundary literals (e.g. `5 BETWEEN 1 AND 3`)

### Automated Quickfix
For `IF`, `WHILE`, and `CHECK` statements with constant false conditions, the `DELDEAD` quickfix removes the dead branch and its enclosing block entirely.

### Suppression
Suppress with pseudo comment `"#EC NO_DEAD_CODE`.


## Related Rules

* [Avoid Unreachable Statements Following Unconditional Exit or Jump Operations](/rules/no-unreachable) — <code>#EC NO_UNREACHABLE</code>
* [Replace Unexplained Magic Numbers with Named Constants](/rules/no-magic-numbers) — <code>#EC NO_MAGIC_NUMBERS</code>
* [Limit Method and Constructor Statement Length](/rules/max-method-len) — <code>#EC MAX_METHOD_LEN</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_DEAD_CODE`
* **ABAP Implementation:** [/skyl/cl_no_dead_code.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_dead_code.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3608)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3608)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_DEAD_CODE&title=%5BBug%5D%3A%20Issue%20in%20no-dead-code)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-dead-code)**
