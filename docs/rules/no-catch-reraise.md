---
title: "Avoid CATCH Handlers That Only Re-raise the Caught Exception"
description: "Identify redundant ABAP CATCH blocks that simply rethrow caught exceptions without adding logging or contextual wrapping."
keywords: "CATCH reraise, ABAP exception handling, Clean ABAP TRY CATCH, SAP ATC check, no-catch-reraise"
category: "anti-patterns"
ruleId: "no-catch-reraise"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4266"
---

# Avoid CATCH Handlers That Only Re-raise the Caught Exception

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_CATCH_RERAISE" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4266" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Detect CATCH blocks that only re-raise the same exception.

> **ATC Finding Message:** `CATCH block only re-raises the same exception; remove it`

## Rationale

Catching an exception only to immediately re-raise the identical exception type or object without logging, cleanup, or enrichment is redundant overhead. It increases call stack depth, obscures the point of failure, and bloats TRY...CATCH control structures. Either delete the unnecessary CATCH clause so the exception propagates naturally up the call stack, or wrap it in a meaningful domain exception using PREVIOUS.

### Non-Compliant

```abap
TRY.
    io_order_gateway->execute_payment( ).
  CATCH cx_payment_processing_error INTO DATA(lx_error).
    RAISE EXCEPTION lx_error.
ENDTRY.
```

### Compliant

```abap
TRY.
    io_order_gateway->execute_payment( ).
  CATCH cx_payment_processing_error INTO DATA(lx_error).
    RAISE EXCEPTION NEW zcx_order_settlement_failed( previous = lx_error ).
ENDTRY.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_CATCH_RERAISE

" SAP CI_ prefix format:
... "#EC CI_NO_CATCH_RERAISE
```

### Handlers inspected

A finding `NO_RETHROW` is reported when a `CATCH` clause contains exactly one statement that re-raises the caught instance or type without extra parameters:

| Catch Block Content | Finding | Explanation |
| --- | --- | --- |
| `CATCH cx_error INTO lx. RAISE EXCEPTION lx.` | yes (`NO_RETHROW`) | Redundant rethrow without enrichment |
| `CATCH cx_error. RAISE EXCEPTION TYPE cx_error.` | yes (`NO_RETHROW`) | Bare re-instantiation of caught type |
| `CATCH cx_error INTO lx. RAISE EXCEPTION NEW zcx_domain( previous = lx ).` | no | Enriches context via chained exception |
| `CATCH cx_error INTO lx. log_error( lx ). RAISE EXCEPTION lx.` | no | Performs intermediate logging |

### Suppression

To retain an explicit rethrow block for debugging breakpoints, annotate the `RAISE` statement with `"#EC NO_CATCH_RERAISE`.


## Related Rules

* [Avoid Generic CATCH cx_root and Catch Specific Exceptions](/rules/no-catch-root) — <code>#EC NO_CATCH_ROOT</code>
* [Preserve Root Cause Exceptions in PREVIOUS Parameter](/rules/no-exc-chain) — <code>#EC NO_EXC_CHAIN</code>
* [Avoid Empty Control Blocks in Branching and Looping Statements](/rules/no-empty-block) — <code>#EC NO_EMPTY_BLOCK</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_CATCH_RERAISE`
* **ABAP Implementation:** [/skyl/cl_no_catch_reraise.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_catch_reraise.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4266)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4266)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_CATCH_RERAISE&title=%5BBug%5D%3A%20Issue%20in%20no-catch-reraise)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-catch-reraise)**
