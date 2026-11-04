---
title: "Replace Obsolete CALL METHOD Statements with Functional Invocations"
description: "Eliminate legacy CALL METHOD statements in favor of modern functional method calls in Clean ABAP and SAP ATC."
keywords: "no-call-method, CALL METHOD, functional method call, Clean ABAP, ABAP Cloud"
category: "anti-patterns"
ruleId: "no-call-method"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L388"
---

# Replace Obsolete CALL METHOD Statements with Functional Invocations

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_CALL_METHOD" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L388" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid static CALL METHOD statements.

> **ATC Finding Message:** `Avoid static CALL METHOD; use functional method call instead`

## Rationale

The explicit CALL METHOD syntax is a legacy holdover from early ABAP Objects releases that introduces excessive syntactic verbosity. In modern Clean ABAP and ABAP Cloud, methods should always be invoked functionally as ref->method( ) or class=>method( ), enabling clean chaining, expression embedding, and streamlined parameter passing. The check reports NO_CALL_MT for static invocations, and the CALL2FUNC quickfix automatically transforms the statement into modern functional syntax.

### Non-Compliant

```abap
CALL METHOD lo_invoice_service->calculate_tax
  EXPORTING
    iv_net_amount = lv_net_amount
  RECEIVING
    rv_tax_amount = lv_tax_amount.
```

### Compliant

```abap
lv_tax_amount = lo_invoice_service->calculate_tax( iv_net_amount = lv_net_amount ).
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
... "#EC NO_CALL_METHOD

" SAP CI_ prefix format:
... "#EC CI_NO_CALL_METHOD
```

### Scope and Dynamic Calls

Static `CALL METHOD` statements are reported with finding `NO_CALL_MT`. Dynamic method calls are intentionally exempted:

- `CALL METHOD lo_instance->(lv_method_name)` (dynamic method name) is ignored.
- `PARAMETER-TABLE` and `EXCEPTION-TABLE` additions are ignored.

The `CALL2FUNC` quickfix automatically strips the `CALL METHOD` keywords and converts parameter clauses into modern parenthesis-enclosed argument lists. Findings can be suppressed with `"#EC NO_CALL_METHOD`.


## Related Rules

* [Omit Redundant EXPORTING Keyword in Method Invocations](/rules/no-call-exporting) — <code>#EC NO_CALL_EXPORTING</code>
* [Omit Explicit RECEIVING Keyword in Functional Method Invocations](/rules/no-call-receiving) — <code>#EC NO_CALL_RECEIVING</code>
* [Avoid Redundant ME-> Self-References to Instance Members](/rules/no-me-reference) — <code>#EC NO_ME_REFERENCE</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_CALL_METHOD`
* **ABAP Implementation:** [/skyl/cl_no_call_method.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_call_method.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 388)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L388)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_CALL_METHOD&title=%5BBug%5D%3A%20Issue%20in%20no-call-method)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-call-method)**
