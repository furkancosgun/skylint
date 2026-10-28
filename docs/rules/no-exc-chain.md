---
title: "Preserve the Original Exception with PREVIOUS"
description: "Ensure ABAP exception conversions keep the original cause by setting PREVIOUS when raising a new exception inside CATCH."
keywords: "ABAP exception chaining, PREVIOUS exception attribute, root cause exception ABAP, SAP ATC exception check, Clean ABAP error handling"
category: "anti-patterns"
ruleId: "no-exc-chain"
---

# Preserve the Original Exception with PREVIOUS

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_EXC_CHAIN" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Preserve the original exception with PREVIOUS.

> **ATC Finding Message:** `Converted exception does not follow the PREVIOUS chaining policy`

## Rationale

When a handler converts an exception into a new one without setting `previous`, the caller loses the root cause and only sees the outer symptom. Passing the caught exception object through the `previous` attribute keeps the full chain available in the stack trace and in RAP error logs. The rule inspects `RAISE EXCEPTION NEW` and `RAISE EXCEPTION TYPE` inside `CATCH ... INTO` handlers.

### Non-Compliant

```abap
TRY.
    lo_http->send( ).
  CATCH cx_http_error INTO lx_http.
    RAISE EXCEPTION NEW zcx_upload_failed( ).
ENDTRY.
```

### Compliant

```abap
TRY.
    lo_http->send( ).
  CATCH cx_http_error INTO lx_http.
    RAISE EXCEPTION NEW zcx_upload_failed( previous = lx_http ).
ENDTRY.
```

## Automated QuickFix

This rule provides an **automated QuickFix** directly in Eclipse ABAP Development Tools (ADT):
1. Position the cursor on the flagged statement.
2. Press <kbd>Ctrl</kbd> + <kbd>1</kbd> (Quick Assist).
3. Select the automated refactoring to apply the clean syntax immediately.

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `REQUIRE_PREVIOUS` | `Boolean` | <code>true</code> | Report converted exceptions without PREVIOUS (default); disable to report the opposite style |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_EXC_CHAIN

" SAP CI_ prefix format:
... "#EC CI_NO_EXC_CHAIN
```


## Related Rules

* [Avoid CATCH Blocks That Only Re-raise the Same Exception](/rules/no-catch-reraise) — <code>#EC NO_CATCH_RERAISE</code>
* [Avoid Catching Generic CX_ROOT (Catch Specific Exceptions)](/rules/no-catch-root) — <code>#EC NO_CATCH_ROOT</code>
* [Prefer Class-Based Exceptions over Classic EXCEPTIONS](/rules/pref-class-exc) — <code>#EC PREF_CLASS_EXC</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_EXC_CHAIN`
* **Implementation File:** [zcl_skylint_no_exc_chain.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_exc_chain.clas.abap)
