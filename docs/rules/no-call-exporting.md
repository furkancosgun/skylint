---
title: "Omit Redundant EXPORTING Keyword in Method Invocations"
description: "Omit redundant EXPORTING keywords in functional ABAP method calls for cleaner and more readable syntax."
keywords: "no-call-exporting, EXPORTING keyword, functional method call, Clean ABAP, SAP ATC"
category: "anti-patterns"
ruleId: "no-call-exporting"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L531"
---

# Omit Redundant EXPORTING Keyword in Method Invocations

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_CALL_EXPORTING" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L531" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Omit Redundant EXPORTING in Method Calls.

> **ATC Finding Message:** `Omit explicit EXPORTING keyword in method invocation`

## Rationale

When invoking a method functionally, the EXPORTING keyword is entirely optional unless another clause (such as IMPORTING, CHANGING, or EXCEPTIONS) is present. Writing out EXPORTING adds redundant boilerplate, clutters method parameter lists, and violates Clean ABAP conciseness principles. The check detects standalone EXPORTING clauses and reports NO_CALL_EX, while the OMIT_EXP quickfix directly deletes the superfluous keyword.

### Non-Compliant

```abap
lo_pricing_engine->apply_discount( EXPORTING iv_discount_rate = 15 ).
```

### Compliant

```abap
lo_pricing_engine->apply_discount( iv_discount_rate = 15 ).
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
... "#EC NO_CALL_EXPORTING

" SAP CI_ prefix format:
... "#EC CI_NO_CALL_EXPORTING
```

### Redundant vs. Mandatory EXPORTING

In functional ABAP method calls, parameters passed without a section header are implicitly treated as `EXPORTING`:

| Syntax Pattern | Status | QuickFix |
|---|---|---|
| `lo_obj->method( EXPORTING iv_val = 1 ).` | Redundant | `OMIT_EXP` removes `EXPORTING` |
| `lo_obj->method( iv_val = 1 ).` | Clean ABAP Standard | Clean |
| `lo_obj->method( EXPORTING iv_val = 1 IMPORTING ev_res = lv_res ).` | Required (multi-section) | Exempt |

The rule ignores calls that contain `IMPORTING`, `CHANGING`, `RECEIVING`, or `EXCEPTIONS`. Suppress findings with `"#EC NO_CALL_EXPORTING`.


## Related Rules

* [Replace Obsolete CALL METHOD Statements with Functional Invocations](/rules/no-call-method) — <code>#EC NO_CALL_METHOD</code>
* [Omit Explicit RECEIVING Keyword in Functional Method Invocations](/rules/no-call-receiving) — <code>#EC NO_CALL_RECEIVING</code>
* [Use RETURNING Instead of a Single EXPORTING Parameter](/rules/pref-returning) — <code>#EC PREF_RETURNING</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_CALL_EXPORTING`
* **ABAP Implementation:** [/skyl/cl_no_call_exporting.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_call_exporting.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 531)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L531)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_CALL_EXPORTING&title=%5BBug%5D%3A%20Issue%20in%20no-call-exporting)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-call-exporting)**
