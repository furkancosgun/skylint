---
title: "Detect Declared But Unused Procedure Parameters"
description: "Find parameters declared in methods, FORM routines and function modules that are never used, and keep procedure signatures honest."
keywords: "no-unused-param, unused parameter, method signature, RTTI, Clean ABAP"
category: "clean-abap"
ruleId: "no-unused-param"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L590"
---

# Detect Declared But Unused Procedure Parameters

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC NO_UNUSED_PARAM" />
  <Badge type="warning" text="Local Only" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L590" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Avoid unused parameters in procedures.

> **ATC Finding Message:** `Parameter(s) &1 never used in procedure`

## Rationale

A parameter that is never read or written clutters the signature, misleads callers into supplying data that is ignored and often marks an implementation that was never finished. The check collects the declared parameters of methods, FORM routines and function modules and compares them with the data references actually used in the body, then reports NO_UNUS_PR listing every unused name at once. Method signatures are read with RTTI, so interface, abstract, redefined, inherited and event-handler methods are skipped instead of producing false positives.

### Non-Compliant

```abap
METHOD post_material_document IMPORTING is_document TYPE ty_material_doc iv_post_date TYPE d.
  DATA lv_posting_date TYPE d.
  lv_posting_date = iv_post_date.
ENDMETHOD.
```

### Compliant

```abap
METHOD post_material_document IMPORTING is_document TYPE ty_material_doc iv_post_date TYPE d.
  DATA lv_posting_date TYPE d.
  lv_posting_date = iv_post_date.
  post_document( is_document ).
ENDMETHOD.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `CHECK_METHODS` | `Boolean` | <code>true</code> | Inspect method implementations through RTTI. Interface, abstract, redefined, inherited methods and event handlers are always skipped. |
| `CHECK_FORMS` | `Boolean` | <code>true</code> | Inspect FORM routine signatures. Disable when legacy form routines are out of scope for the cleanup. |
| `CHECK_FUNCS` | `Boolean` | <code>true</code> | Inspect function module signatures. Disable when function modules are maintained by another team. |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_UNUSED_PARAM

" SAP CI_ prefix format:
... "#EC CI_NO_UNUSED_PARAM
```

## Scope and Exceptions

| Aspect | Behaviour |
|---|---|
| Procedures | Methods (`CHECK_METHODS`), FORM routines (`CHECK_FORMS`) and function modules (`CHECK_FUNCS`) |
| Always skipped | `RETURNING` parameters and parameters whose name starts with `_` |
| Methods skipped | interface, abstract, redefined, inherited methods and event handlers |
| Finding | `NO_UNUS_PR` on the first statement of the procedure, listing all unused names |

Method signatures are resolved through RTTI, therefore `remote_enablement = abap_false`. Prefix a deliberately unused parameter with an underscore to document the intent instead of deleting it, for example a callback signature that must match an interface.


## Related Rules

* [Omit or Require Parameter Names in Method Calls](/rules/pref-param-name) — <code>#EC PREF_PARAM_NAME</code>
* [Limit Method Parameter Count and Keep One Parameter per Line](/rules/max-params) — <code>#EC MAX_PARAMS_COUNT</code>
* [Remove Unread Local Variables and Field Symbols](/rules/no-unused-vars) — <code>#EC NO_UNUSED_VARS</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_UNUSED_PARAM`
* **ABAP Implementation:** [/skyl/cl_no_unused_param.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_unused_param.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 590)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L590)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_UNUSED_PARAM&title=%5BBug%5D%3A%20Issue%20in%20no-unused-param)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-unused-param)**
