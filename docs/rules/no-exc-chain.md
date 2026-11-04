---
title: "Preserve Root Cause Exceptions in PREVIOUS Parameter"
description: "Enforce PREVIOUS parameter chaining in ABAP exception handling to retain root cause error diagnostics in SAP ATC."
keywords: "ABAP exception chaining, PREVIOUS parameter, Clean ABAP exceptions, SAP ATC check, no-exc-chain"
category: "anti-patterns"
ruleId: "no-exc-chain"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4326"
---

# Preserve Root Cause Exceptions in PREVIOUS Parameter

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC NO_EXC_CHAIN" />
  <Badge type="info" text="Remote Enabled" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L4326" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Preserve the original exception with PREVIOUS.

> **ATC Finding Message:** `Converted exception does not follow the PREVIOUS chaining policy`

## Rationale

When converting a low-level technical exception into an application or business exception inside a CATCH block, omitting the PREVIOUS parameter discards the root cause exception and its stack trace. In ABAP Cloud and SAP S/4HANA RAP architectures, missing exception chains make root cause analysis in production telemetry and application logs extremely difficult. Chaining the caught exception preserves full diagnostic context.

### Non-Compliant

```abap
TRY.
    mo_payment_gateway->authorize_payment( ).
  CATCH cx_http_communication_failure INTO DATA(lx_comm_err).
    RAISE EXCEPTION NEW zcx_checkout_exception( ).
ENDTRY.
```

### Compliant

```abap
TRY.
    mo_payment_gateway->authorize_payment( ).
  CATCH cx_http_communication_failure INTO DATA(lx_comm_err).
    RAISE EXCEPTION NEW zcx_checkout_exception( previous = lx_comm_err ).
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
| `REQUIRE_PREVIOUS` | `Boolean` | <code>true</code> | Enforce passing caught exceptions via PREVIOUS when raising new exceptions in CATCH handlers (default true). |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_EXC_CHAIN

" SAP CI_ prefix format:
... "#EC CI_NO_EXC_CHAIN
```

### Exception chaining and quickfixes

The check inspects `RAISE EXCEPTION NEW` and `RAISE EXCEPTION TYPE` statements inside `CATCH ... INTO <var>` blocks:

| Statement in CATCH Block | Finding | Quickfix Available |
| --- | --- | --- |
| `RAISE EXCEPTION NEW zcx_err( ).` | yes (`NO_EXCCHN`) | yes (`ADD_PREV` appends `previous = lx_err`) |
| `RAISE EXCEPTION TYPE zcx_err.` | yes (`NO_EXCCHN`) | yes (`ADD_PREV` adds `EXPORTING previous = lx_err`) |
| `RAISE EXCEPTION NEW zcx_err( previous = lx_err ).` | no | none required |

### Suppression

If an exception is deliberately sanitized to prevent leaking sensitive infrastructure details to callers, suppress with `"#EC NO_EXC_CHAIN`.


## Related Rules

* [Avoid CATCH Handlers That Only Re-raise the Caught Exception](/rules/no-catch-reraise) — <code>#EC NO_CATCH_RERAISE</code>
* [Avoid Generic CATCH cx_root and Catch Specific Exceptions](/rules/no-catch-root) — <code>#EC NO_CATCH_ROOT</code>
* [Prefer Class-Based Exceptions over Classic EXCEPTIONS](/rules/pref-class-exc) — <code>#EC PREF_CLASS_EXC</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_EXC_CHAIN`
* **ABAP Implementation:** [/skyl/cl_no_exc_chain.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_exc_chain.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 4326)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L4326)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_EXC_CHAIN&title=%5BBug%5D%3A%20Issue%20in%20no-exc-chain)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-exc-chain)**
