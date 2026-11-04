---
title: "Capture and Consume Return Values of Functional Method Calls"
description: "Ensure return values of functional method calls are consumed rather than ignored in ABAP Cloud and Clean ABAP code."
keywords: "no-ignored-return, Clean ABAP, ABAP Cloud, functional method, RETURNING value, SAP ATC"
category: "anti-patterns"
ruleId: "no-ignored-return"
customEditUrl: "https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3284"
---

# Capture and Consume Return Values of Functional Method Calls

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC NO_IGNORED_RETURN" />
  <Badge type="warning" text="Local Only" />
  <a href="https://github.com/furkancosgun/skylint/edit/main/scripts/rules-data.mjs#L3284" target="_blank" rel="noopener noreferrer" style="display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 6px; background: var(--vp-c-default-soft); color: var(--vp-c-text-2); text-decoration: none;">✏️ Edit Rule on GitHub</a>
</div>

## Overview

Disallow ignoring the return value of functional methods.

> **ATC Finding Message:** `Do not ignore return value of functional method; assign or use result`

## Rationale

Invoking a functional method without capturing its RETURNING parameter indicates either a useless statement that wastes CPU cycles or a poorly designed method that hides state mutations behind a query signature. Clean ABAP requires methods with return values to be functional queries whose results are assigned, evaluated in an expression, or passed to downstream procedures. Discarding the return value leaves side effects unexpected and makes code intent unreadable. The ATC check uses RTTI to detect uncaptured functional calls and reports NO_IGN_RET.

### Non-Compliant

```abap
lo_pricing_engine->calculate_total_price( iv_order_id = lv_order_id ).
```

### Compliant

```abap
DATA(lv_total_price) = lo_pricing_engine->calculate_total_price( iv_order_id = lv_order_id ).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_IGNORED_RETURN

" SAP CI_ prefix format:
... "#EC CI_NO_IGNORED_RETURN
```

## Detection Details

The check evaluates standalone method call statements (`+CALL_METHOD` or `CALL METHOD`). It uses runtime type inspection (`/skyl/cl_rtti_util=>get_method_descr`) to examine the method signature. If the invoked method declares a `RETURNING` parameter and the call site neither assigns the result nor uses the `RECEIVING` addition, finding code `NO_IGN_RET` is reported.

### Remote Enablement Notice
Because this rule inspects type descriptors at runtime via RTTI, it cannot be executed in RFC remote ATC scenarios and has `remote_enablement = abap_false`.

### Suppression
Suppress with pseudo comment `"#EC NO_IGNORED_RETURN`.


## Related Rules

* [Use RETURN Instead of EXIT Outside Loops](/rules/pref-return) — <code>#EC PREF_RETURN</code>
* [Omit Redundant RETURN Statement at the End of Routines](/rules/no-unnec-return) — <code>#EC NO_UNNEC_RETURN</code>
* [Separate Functional RETURNING Parameters from EXPORTING and CHANGING Outputs](/rules/no-mix-returning) — <code>#EC NO_MIX_RETURNING</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_IGNORED_RETURN`
* **ABAP Implementation:** [/skyl/cl_no_ignored_return.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_ignored_return.clas.abap)
* **Rule Metadata:** [rules-data.mjs (Line 3284)](https://github.com/furkancosgun/skylint/blob/main/scripts/rules-data.mjs#L3284)

## Community & Feedback

* 🐛 **[Report a False Positive or Bug for this rule](https://github.com/furkancosgun/skylint/issues/new?template=bug_report.yml&rule_id=%2FSKYL%2FCL_NO_IGNORED_RETURN&title=%5BBug%5D%3A%20Issue%20in%20no-ignored-return)**
* 💡 **[Suggest a QuickFix or Rule Improvement](https://github.com/furkancosgun/skylint/issues/new?template=feature_request.yml&title=%5BProposal%5D%3A%20Enhance%20no-ignored-return)**
