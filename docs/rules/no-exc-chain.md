---
title: "Preserve the Original Exception with PREVIOUS"
description: "Ensure ABAP exception conversions keep the original cause by setting PREVIOUS when raising a new exception inside CATCH."
keywords: "ABAP exception chaining, PREVIOUS exception attribute, root cause exception ABAP, SAP ATC exception check, Clean ABAP error handling"
category: "anti-patterns"
ruleId: "no-exc-chain"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4225"
---

# Preserve the Original Exception with PREVIOUS

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_EXC_CHAIN" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4225" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
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

* **Native ATC Class:** `/SKYL/CL_NO_EXC_CHAIN`
* **ABAP Implementation:** [/skyl/cl_no_exc_chain.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_exc_chain.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4225)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4225)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_EXC_CHAIN&title=%5BBug%5D%3A%20Issue%20in%20no-exc-chain)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-exc-chain)**
