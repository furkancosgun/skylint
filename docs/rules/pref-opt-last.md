---
title: "Declare Optional and Default Parameters Last in Methods"
description: "Improve method readability in ABAP by placing optional and default parameters after mandatory parameters."
keywords: "Clean ABAP Parameters, OPTIONAL Parameter Order, DEFAULT Parameter, Method Signature Hygiene"
category: "clean-abap"
ruleId: "pref-opt-last"
---

# Declare Optional and Default Parameters Last in Methods

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_OPTIONAL_LAST" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Declare optional and default parameters last in methods.

> **ATC Finding Message:** `Declare mandatory parameters before OPTIONAL and DEFAULT parameters`

## Rationale

In Clean ABAP, mandatory parameters must appear before optional (`OPTIONAL`) and default (`DEFAULT`) parameters in method signatures. Mixing optional and required parameters makes caller invocation confusing and error-prone.

**Standard:** Place required parameters first, followed by optional parameters at the end of the parameter list.

### Non-Compliant

```abap
METHODS process_data
  IMPORTING
    iv_opt TYPE i OPTIONAL
    iv_req TYPE i.
```

### Compliant

```abap
METHODS process_data
  IMPORTING
    iv_req TYPE i
    iv_opt TYPE i OPTIONAL.
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_OPTIONAL_LAST

" SAP CI_ prefix format:
... "#EC CI_PREF_OPTIONAL_LAST
```


## Related Rules

* [Method Call Parameter Naming Style (Omit or Require)](/rules/pref-param-name) — <code>#EC PREF_PARAM_NAME</code>
* [Single Parameter or Field Per Line](/rules/pref-param-1line) — <code>#EC PREF_PARAM_1LINE</code>
* [Limit Method Parameter Count and Require Multi-Line Signatures](/rules/max-params) — <code>#EC MAX_PARAMS_COUNT</code>

## Technical Details

* **Native ATC Class:** `/SKYL/CL_PREF_OPT_LAST`
* **Implementation File:** [#skyl#cl_pref_opt_last.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/rules/%23skyl%23cl_pref_opt_last.clas.abap)
