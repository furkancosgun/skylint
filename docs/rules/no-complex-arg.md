---
title: "Avoid Complex Expressions in Call Arguments"
description: "Report complex expressions and nested method chains in method call arguments."
keywords: "no-complex-arg, complex arguments, method call arguments, argument complexity, Clean ABAP"
category: "clean-abap"
ruleId: "no-complex-arg"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L6116"
---

# Avoid Complex Expressions in Call Arguments

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC NO_COMPLEX_ARG" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L6116" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid complex expressions in call arguments.

> **ATC Finding Message:** `Avoid complex expressions in call arguments; extract into a variable`

## Rationale

Method call arguments should be simple variables, literals, or single method calls. Nesting deep method chains or complex expressions like COND #( ... ) inside arguments reduces readability and makes debugging difficult. Extract complex expressions into local variables before the call.

### Non-Compliant

```abap
lo_service->process( iv_param = lo_factory->get_builder( )->build( ) ).
```

### Compliant

```abap
DATA(lo_item) = lo_factory->get_builder( )->build( ).
lo_service->process( iv_param = lo_item ).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_COMPLEX_ARG

" SAP CI_ prefix format:
... "#EC CI_NO_COMPLEX_ARG
```


## Related Rules

* [Avoid Method Call Chains Longer Than the Configured Limit](/rules/no-method-chain) — <code>#EC NO_METHOD_CHAIN</code>
* [Enforce Cognitive Complexity Thresholds per Procedure](/rules/max-cognitive) — <code>#EC MAX_COGNITIVE</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_COMPLEX_ARG`
* **ABAP Implementation:** [/skyl/cl_no_complex_arg.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_complex_arg.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 6116)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L6116)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_COMPLEX_ARG&title=%5BBug%5D%3A%20Issue%20in%20no-complex-arg)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-complex-arg)**
