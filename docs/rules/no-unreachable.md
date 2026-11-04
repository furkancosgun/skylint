---
title: "Avoid Unreachable Statements Following Unconditional Exit or Jump Operations"
description: "Detect and remove unreachable dead statements after unconditional RETURN, EXIT, or RAISE in Clean ABAP."
keywords: "no-unreachable, unreachable code, dead code, unconditional RETURN, SAP ATC"
category: "anti-patterns"
ruleId: "no-unreachable"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L920"
---

# Avoid Unreachable Statements Following Unconditional Exit or Jump Operations

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_UNREACHABLE" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L920" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Detect unreachable code after jump or exit statements.

> **ATC Finding Message:** `Statement is unreachable`

## Rationale

Statements positioned directly after an unconditional RETURN, EXIT, CONTINUE, RAISE EXCEPTION, or RAISE SHORTDUMP can never be reached by program execution flow. Such dead code typically remains from earlier debugging sessions, unfinished refactoring, or copy-paste errors, creating confusion for future maintainers and distorting unit test coverage calculations. Clean ABAP mandates removing dead code or moving statements prior to the terminating statement if their execution is required. The check reports NO_UNREACH and provides the DELSTMT quickfix to delete unreachable statements.

### Non-Compliant

```abap
RETURN.
lv_processed_count = lv_processed_count + 1.
```

### Compliant

```abap
lv_processed_count = lv_processed_count + 1.
RETURN.
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
... "#EC NO_UNREACHABLE

" SAP CI_ prefix format:
... "#EC CI_NO_UNREACHABLE
```

### Unconditional Jump Recognition

The rule identifies statements directly following any of the following unconditional jump operations at the same block depth:

| Unconditional Jump | Scope of Unreachable Code | QuickFix |
|---|---|---|
| `RETURN` | Statements following until `ENDMETHOD` / `ENDFORM` | `DELSTMT` |
| `EXIT` | Statements following until `ENDLOOP` / `ENDDO` / `ENDWHILE` | `DELSTMT` |
| `CONTINUE` | Statements following until `ENDLOOP` / `ENDDO` / `ENDWHILE` | `DELSTMT` |
| `RAISE EXCEPTION` (non-resumable) | Statements following until enclosing block end | `DELSTMT` |
| `RAISE SHORTDUMP` | Statements following until enclosing block end | `DELSTMT` |

`RAISE RESUMABLE EXCEPTION` is recognized as resumable and does not mark subsequent statements unreachable. Suppress findings using `"#EC NO_UNREACHABLE`.


## Related Rules

* [Eliminate Unreachable Dead Code Caused by Constant False Conditions](/rules/no-dead-code) — <code>#EC NO_DEAD_CODE</code>
* [Replace Unexplained Magic Numbers with Named Constants](/rules/no-magic-numbers) — <code>#EC NO_MAGIC_NUMBERS</code>
* [Limit Method and Constructor Statement Length](/rules/max-method-len) — <code>#EC MAX_METHOD_LEN</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_UNREACHABLE`
* **ABAP Implementation:** [/skyl/cl_no_unreachable.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_unreachable.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 920)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L920)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_UNREACHABLE&title=%5BBug%5D%3A%20Issue%20in%20no-unreachable)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-unreachable)**
