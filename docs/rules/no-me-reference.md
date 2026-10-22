---
description: "Avoid self-reference ME->"
---

# Avoid Redundant ME-> Self Reference

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Anti-Patterns & Bad Practices" />
  <Badge type="danger" text="#EC ME" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Avoid self-reference ME->.

> **ATC Finding Message:** `Avoid unnecessary ME-> reference`

## Rationale

Member variables and methods are already accessible inside an instance method, so prefixing every access with me-> only adds noise. Removing the prefix keeps attention on the member itself and makes genuine shadowing easier to spot. Keep me-> only where a parameter or local variable shadows the member, typically in constructors and setters.

### Non-Compliant

```abap
me->mv_order_count = me->mv_order_count + 1.
me->save( ).
```

### Compliant

```abap
mv_order_count = mv_order_count + 1.
save( ).
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value |
|---|---|:---:|
| `ALLOW_IN_CONSTRUCTORS` | `Boolean` | <code>true</code> |

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC ME

" SAP CI_ prefix format:
... "#EC CI_ME
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_NO_ME_REFERENCE`
* **Implementation File:** [zcl_skylint_no_me_reference.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_no_me_reference.clas.abap)
