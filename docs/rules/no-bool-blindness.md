---
title: "Avoid Boolean Flag Importing Parameters"
description: "Detect boolean flag importing parameters in ABAP method signatures and replace boolean blindness with dedicated, self-explanatory APIs."
keywords: "ABAP boolean parameter, boolean blindness, Clean ABAP method signature, SAP ATC check boolean flag, abap_bool importing parameter"
category: "clean-abap"
ruleId: "no-bool-blindness"
---

# Avoid Boolean Flag Importing Parameters

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC NO_BOOL_BLINDNESS" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid boolean flag importing parameters.

> **ATC Finding Message:** `Boolean importing parameters hide intent; use dedicated methods or a typed flag`

## Rationale

A boolean importing parameter turns a method call into a positional switch: callers write do_work( abap_true ) and readers cannot tell what true means without opening the signature. Boolean blindness also pushes every new variation into the same method instead of a dedicated, well-named API. Expose the alternatives as separate methods or as a meaningful typed flag, and keep abap_bool flags out of method interfaces.

### Non-Compliant

```abap
METHODS save_order
  IMPORTING iv_send_mail TYPE abap_bool.
```

### Compliant

```abap
METHODS save_order.
METHODS save_and_send_order.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_BOOL_BLINDNESS

" SAP CI_ prefix format:
... "#EC CI_NO_BOOL_BLINDNESS
```


## Related Rules

* [Use Predicate Naming for Boolean Methods (is_, has_, can_)](/rules/pref-pred-name) — <code>#EC PREF_PRED_NAME</code>
* [Avoid Comparing to abap_true / abap_false](/rules/no-bool-compare) — <code>#EC NO_BOOL_COMPARE</code>
* [Limit Method Parameter Count and Require Multi-Line Signatures](/rules/max-params) — <code>#EC MAX_PARAMS_COUNT</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_BOOL_BLINDNESS`
* **Implementation File:** [zcl_skylint_no_bool_blindness.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_bool_blindness.clas.abap)
