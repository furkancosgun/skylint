---
title: "Omit Explicit RECEIVING Keyword in Functional Method Invocations"
description: "Omit redundant RECEIVING keywords and capture method results via direct left-hand side assignments in Clean ABAP."
keywords: "no-call-receiving, RECEIVING clause, functional method call, Clean ABAP, SAP ATC"
category: "anti-patterns"
ruleId: "no-call-receiving"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L503"
---

# Omit Explicit RECEIVING Keyword in Functional Method Invocations

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_CALL_RECEIVING" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L503" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Omit RECEIVING in Method Invocations.

> **ATC Finding Message:** `Omit RECEIVING keyword; use functional call or omit parameter`

## Rationale

The explicit RECEIVING clause inside a method invocation forces functional calls into procedural statement syntax, preventing the returned value from participating in larger expressions or inline assignments. In Clean ABAP and ABAP Cloud, returning values should be assigned directly to the left-hand side of an assignment (e.g. result = obj->calc( )). The check identifies RECEIVING clauses in functional calls and flags them with NO_CALL_RC, while the OMITRECV quickfix hoists the receiving target variable to the LHS.

### Non-Compliant

```abap
lo_order_service->calculate_total_price( RECEIVING rv_total = lv_total_price ).
```

### Compliant

```abap
lv_total_price = lo_order_service->calculate_total_price( ).
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
... "#EC NO_CALL_RECEIVING

" SAP CI_ prefix format:
... "#EC CI_NO_CALL_RECEIVING
```

### Syntax Modernization and QuickFix

In functional ABAP method calls, the `RECEIVING` keyword is an obsolete verbosity from procedural styles:

```abap
" Legacy procedural style:
lo_calculator->get_factor( RECEIVING rv_factor = lv_factor ).

" Modern Clean ABAP style:
lv_factor = lo_calculator->get_factor( ).
```

Methods with non-class-based `EXCEPTIONS` clauses are ignored because classic exceptions cannot be captured on the left-hand side of an expression. The `OMITRECV` quickfix extracts the receiving variable and rewrites the statement into an LHS assignment. Suppress findings with `"#EC NO_CALL_RECEIVING`.


## Related Rules

* [Replace Obsolete CALL METHOD Statements with Functional Invocations](/rules/no-call-method) — <code>#EC NO_CALL_METHOD</code>
* [Omit Redundant EXPORTING Keyword in Method Invocations](/rules/no-call-exporting) — <code>#EC NO_CALL_EXPORTING</code>
* [Use RETURNING Instead of a Single EXPORTING Parameter](/rules/pref-returning) — <code>#EC PREF_RETURNING</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_CALL_RECEIVING`
* **ABAP Implementation:** [/skyl/cl_no_call_receiving.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_call_receiving.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 503)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L503)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_CALL_RECEIVING&title=%5BBug%5D%3A%20Issue%20in%20no-call-receiving)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-call-receiving)**
