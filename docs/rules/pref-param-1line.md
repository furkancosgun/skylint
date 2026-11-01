---
title: "Single Parameter or Field Per Line"
description: "Enforce one parameter or field assignment per line in multi-argument calls."
keywords: "Clean ABAP, parameter per line, pref-param-1line"
category: "clean-abap"
ruleId: "pref-param-1line"
---

# Single Parameter or Field Per Line

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_PARAM_1LINE" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Parameters and structure fields must be on separate lines.

> **ATC Finding Message:** `Multiple parameters or fields on the same line; place each on a separate line`

## Rationale

When passing multiple parameters in method calls or constructor expressions, place each parameter or field on its own separate line.

### Non-Compliant

```abap
ls_data = VALUE #( a = 1 b = 2 ).
```

### Compliant

```abap
ls_data = VALUE #(
    a = 1
    b = 2 ).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_PARAM_1LINE

" SAP CI_ prefix format:
... "#EC CI_PREF_PARAM_1LINE
```


## Related Rules

* [Avoid Consecutive Whitespace Between Tokens](/rules/no-double-space) — <code>#EC NO_DOUBLE_SPACE</code>
* [Limit Method and Constructor Statement Length](/rules/max-method-len) — <code>#EC MAX_METHOD_LEN</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_PARAM_1LINE`
* **Implementation File:** [zcl_skylint_pref_param_1line.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_param_1line.clas.abap)
