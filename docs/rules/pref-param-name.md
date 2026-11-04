---
title: "Omit or Require Parameter Names in Method Calls"
description: "Enforce one method call style: omit the parameter name for single-parameter methods or require explicit names via REQUIRE_PARAM_NAME."
keywords: "pref-param-name, parameter name, functional method call, RTTI, Clean ABAP"
category: "clean-abap"
ruleId: "pref-param-name"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L559"
---

# Omit or Require Parameter Names in Method Calls

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="warning" text="QuickFix Ready" />
  <Badge type="danger" text="#EC PREF_PARAM_NAME" />
  <Badge type="warning" text="Local Only" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L559" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Method Call Parameter Naming Style.

> **ATC Finding Messages:**
> - `Omit explicit parameter name in single parameter method call`
> - `Add explicit parameter name to positional method call`

## Rationale

For a method with exactly one IMPORTING parameter, writing the parameter name at every call site adds noise without adding information. For teams that prefer explicit names, the opposite style is enforced instead. The check reads the method signature with RTTI to confirm the single-parameter case and reports PREF_OMIT or PREF_REQ_P accordingly, each with its own quickfix that edits the call in place. Because the signature must be resolved at runtime, the rule is not remote enabled and only runs locally.

### Non-Compliant

```abap
DATA(lo_pricing_service) = NEW zcl_pricing_service( ).
lo_pricing_service->apply_discount( iv_percent = 15 ).
```

### Compliant

```abap
DATA(lo_pricing_service) = NEW zcl_pricing_service( ).
lo_pricing_service->apply_discount( 15 ).
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
| `CHECK_PARAM_NAME` | `Boolean` | <code>true</code> | Report single-IMPORTING-parameter calls that still pass the parameter name and suggest the positional form. Ignored while REQUIRE_PARAM_NAME is active. |
| `REQUIRE_PARAM_NAME` | `Boolean` | <code>false</code> | Report positional calls to single-IMPORTING-parameter methods and add the parameter name. Takes precedence over CHECK_PARAM_NAME. |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_PARAM_NAME

" SAP CI_ prefix format:
... "#EC CI_PREF_PARAM_NAME
```

## Two Modes, One Rule

| Attribute | Finding code | Effect |
|---|---|---|
| `CHECK_PARAM_NAME` (default) | `PREF_OMIT` | A method with exactly one IMPORTING parameter called as `method( iv_param = value )` is reported; the name should be dropped. |
| `REQUIRE_PARAM_NAME` | `PREF_REQ_P` | A positional call `method( value )` is reported and the parameter name is added. Takes precedence over `CHECK_PARAM_NAME` when both are enabled. |

Signatures are resolved through RTTI (`/skyl/cl_rtti_util=>get_single_importing_param`), so the check sets `remote_enablement = abap_false` and cannot run in a remote ATC scenario. Classic `CALL METHOD` statements and calls that use explicit parameter sections are skipped, and the pseudo comment `PREF_PARAM_NAME` suppresses both finding codes.


## Related Rules

* [Limit Method Parameter Count and Keep One Parameter per Line](/rules/max-params) — <code>#EC MAX_PARAMS_COUNT</code>
* [Replace Obsolete CALL METHOD Statements with Functional Invocations](/rules/no-call-method) — <code>#EC NO_CALL_METHOD</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_PARAM_NAME`
* **ABAP Implementation:** [/skyl/cl_pref_param_name.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_param_name.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 559)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L559)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_PREF_PARAM_NAME&title=%5BBug%5D%3A%20Issue%20in%20pref-param-name)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20pref-param-name)**
