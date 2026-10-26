---
title: "Avoid CATCH Blocks That Only Re-raise the Same Exception"
description: "Find ABAP CATCH blocks that only rethrow the same exception without adding context, so redundant handlers can be removed safely."
keywords: "ABAP exception handling, rethrow exception CATCH, Clean ABAP TRY CATCH, SAP ATC exception check, redundant CATCH block"
category: "anti-patterns"
ruleId: "no-catch-reraise"
---

# Avoid CATCH Blocks That Only Re-raise the Same Exception

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_CATCH_RERAISE" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Detect CATCH blocks that only re-raise the same exception.

> **ATC Finding Message:** `CATCH block only re-raises the same exception; remove it`

## Rationale

A CATCH block whose only statement re-raises the identical exception type adds no value: the handler is logically transparent and only adds noise, stack depth and maintenance cost. Either remove the CATCH clause and let the exception propagate, or enrich it with context (`previous`, a domain exception, or message text). This rule only reports blocks that consist of exactly one bare re-raise statement.

### Non-Compliant

```abap
TRY.
    lo_service->run( ).
  CATCH zcx_service_error.
    RAISE EXCEPTION TYPE zcx_service_error.
ENDTRY.
```

### Compliant

```abap
TRY.
    lo_service->run( ).
  CATCH zcx_service_error INTO lx_error.
    RAISE EXCEPTION NEW zcx_service_error( previous = lx_error ).
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


## Related Rules

* [Avoid Catching Generic CX_ROOT (Catch Specific Exceptions)](/rules/no-catch-root) — <code>#EC NO_CATCH_ROOT</code>
* [Preserve the Original Exception with PREVIOUS](/rules/no-exc-chain) — <code>#EC NO_EXC_CHAIN</code>
* [Avoid Empty Control Blocks](/rules/no-empty-block) — <code>#EC NO_EMPTY_BLOCK</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_CATCH_RERAISE`
* **Implementation File:** [zcl_skylint_no_catch_reraise.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_catch_reraise.clas.abap)
