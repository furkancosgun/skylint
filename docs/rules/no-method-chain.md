---
title: "Avoid Excessive Method Chaining"
description: "Limit method chaining depth to maintain readable, debuggable code."
keywords: "Clean ABAP, method chaining, no-method-chain"
category: "clean-abap"
ruleId: "no-method-chain"
---

# Avoid Excessive Method Chaining

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC NO_METHOD_CHAIN" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid excessive method chaining; extract into variables.

> **ATC Finding Message:** `Excessive method chaining; extract intermediate results into variables`

## Rationale

Chaining multiple method calls together degrades readability and makes debugging difficult. Extract intermediate results into explanatory local variables.

### Non-Compliant

```abap
lo_demo->meth1( )->meth2( ).
```

### Compliant

```abap
DATA(lo_step) = lo_demo->meth1( ).
lo_step->meth2( ).
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value | Description & Guidance |
|---|---|:---:|---|
| `MAX_CHAIN` | `Integer` | <code>1</code> | Maximum allowed chained calls (defaults to 1) |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NO_METHOD_CHAIN

" SAP CI_ prefix format:
... "#EC CI_NO_METHOD_CHAIN
```


## Related Rules

* [Avoid Obsolete CALL METHOD](/rules/no-call-method) — <code>#EC NO_CALL_METHOD</code>
* [Limit Method and Constructor Statement Length](/rules/max-method-len) — <code>#EC MAX_METHOD_LEN</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_NO_METHOD_CHAIN`
* **Implementation File:** [#skyl#cl_no_method_chain.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_no_method_chain.clas.abap)
