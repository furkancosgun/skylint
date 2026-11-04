---
title: "Avoid Comparing Boolean Method Calls to abap_true or abap_false"
description: "Avoid comparing boolean predicate method calls to abap_true or abap_false in Clean ABAP conditions."
keywords: "no-bool-compare, predicate method, boolean comparison, abap_true, Clean ABAP"
category: "anti-patterns"
ruleId: "no-bool-compare"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L710"
---

# Avoid Comparing Boolean Method Calls to abap_true or abap_false

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_BOOL_COMPARE" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L710" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid comparing boolean method calls to boolean literals.

> **ATC Finding Message:** `Avoid boolean comparison for method calls; call method directly`

## Rationale

Predicate methods that return a boolean flag (abap_bool) can be called directly within IF, ELSEIF, CHECK, and WHILE conditions. Comparing such method invocations to abap_true or abap_false is redundant, adds unnecessary syntax clutter, and obscures the predicate intent of the call. In Clean ABAP and ABAP Cloud, invoke the boolean-returning method directly as a predicate expression, using NOT when asserting the false condition. The check flags redundant comparisons with NO_BOOL_CM and offers the DROPBOOL quickfix to remove the literal.

### Non-Compliant

```abap
IF lo_permission_checker->is_authorized( ) = abap_true.
  process_payment( ).
ENDIF.
```

### Compliant

```abap
IF lo_permission_checker->is_authorized( ).
  process_payment( ).
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
... "#EC NO_BOOL_COMPARE

" SAP CI_ prefix format:
... "#EC CI_NO_BOOL_COMPARE
```

### Predicate Expressions and QuickFix

In ABAP Cloud and modern kernel versions, methods returning an `abap_bool` parameter serve directly as conditional predicates:

| Redundant Comparison | Clean ABAP Replacement |
|---|---|
| `IF lo_auth->is_valid( ) = abap_true.` | `IF lo_auth->is_valid( ).` |
| `IF lo_auth->is_valid( ) <> abap_false.` | `IF lo_auth->is_valid( ).` |
| `IF lo_auth->is_valid( ) = abap_false.` | `IF NOT lo_auth->is_valid( ).` |

The `DROPBOOL` quickfix automatically removes `= abap_true` or `<> abap_false`. Variable comparisons (`IF lv_flag = abap_true.`) are not reported because bare variable predicates (`IF lv_flag.`) are restricted in ABAP Cloud. Suppress findings using `"#EC NO_BOOL_COMPARE`.


## Related Rules

* [Limit Boolean Expression Complexity in Conditional Statements](/rules/max-bool-expr) — <code>#EC MAX_BOOL_EXPR</code>
* [Replace Single-Branch CASE Statements with IF Conditions](/rules/no-single-when) — <code>#EC NO_SINGLE_WHEN</code>
* [Avoid CHECK Statements Inside and Outside Iteration Loops](/rules/no-check-stmt) — <code>#EC NO_CHECK_IN_LOOP</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_BOOL_COMPARE`
* **ABAP Implementation:** [/skyl/cl_no_bool_compare.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_bool_compare.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 710)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L710)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_BOOL_COMPARE&title=%5BBug%5D%3A%20Issue%20in%20no-bool-compare)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-bool-compare)**
