---
description: "Standard Naming Conventions"
---

# Enforce Naming Conventions

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC NAMING" />
</div>

## Overview

Standard Naming Conventions.

> **ATC Finding Messages:**
> - `Class attribute name does not match configured pattern`
> - `Method parameter name does not match configured pattern`
> - `Local variable name does not match configured pattern`
> - `Local class name does not match configured pattern`
> - `Global class name does not match configured pattern`
> - `Selection screen element name does not match configured pattern`
> - `Type name does not match configured pattern`
> - `Macro name does not match configured pattern`
> - `Form routine name does not match configured pattern`
> - `Function module name does not match configured pattern`
> - `Local interface name does not match configured pattern`
> - `Global interface name does not match configured pattern`
> - `Event or event handler name does not match configured pattern`
> - `Test method name does not match configured pattern`
> - `Program name does not match configured pattern`
> - `Function group name does not match configured pattern`

## Rationale

Consistent naming conventions (prefixes for variables, parameters, types, etc.) make code self-documenting and easier to navigate. Configure patterns per scope to enforce team standards automatically.

### Non-Compliant

```abap
DATA foo TYPE i.
```

### Compliant

```abap
DATA lv_foo TYPE i.
```

## Transformation

```diff
- DATA foo TYPE i.
+ DATA lv_foo TYPE i.
```

## Configuration & Thresholds

This check can be fine-tuned directly in the ATC Check Variant Editor (`CHKV`) in Eclipse ADT:

| Parameter Name | Data Type | Default Value |
|---|---|:---:|
| `ATTR_IGN_EXC` | `Boolean` | <code>true</code> |
| `ATTR_IGN_LOCAL` | `Boolean` | <code>true</code> |
| `ATTR_IGN_INTF` | `Boolean` | <code>false</code> |
| `ATTR_STATICS` | `Integer / String` | <code>'^G._.+$'</code> |
| `ATTR_INSTANCE` | `Integer / String` | <code>'^M._.+$'</code> |
| `ATTR_CONSTANTS` | `Integer / String` | <code>''</code> |
| `PARAM_IGN_EXC` | `Boolean` | <code>true</code> |
| `PARAM_IMPORTING` | `Integer / String` | <code>'^I._.+$'</code> |
| `PARAM_RETURNING` | `Integer / String` | <code>'^R._.+$'</code> |
| `PARAM_CHANGING` | `Integer / String` | <code>'^C._.+$'</code> |
| `PARAM_EXPORTING` | `Integer / String` | <code>'^E._.+$'</code> |
| `LOCAL_DATA` | `Integer / String` | <code>'^L._.+$'</code> |
| `LOCAL_CONST` | `Integer / String` | <code>'^LC_.+$'</code> |
| `LOCAL_FS` | `Integer / String` | <code>'^<L._.+>$'</code> |
| `LOCAL_STATICS` | `Integer / String` | <code>'^S._.+$'</code> |
| `CLASS_LOCAL` | `Integer / String` | <code>'^LC(L&#124;X)_.+$'</code> |
| `CLASS_TEST` | `Integer / String` | <code>'^LTCL_.+$'</code> |
| `CLASS_GLOBAL` | `Integer / String` | <code>'^ZC(L&#124;X)_.+$'</code> |
| `SSCR_PARAM` | `Integer / String` | <code>'^P_.+$'</code> |
| `SSCR_SELOPT` | `Integer / String` | <code>'^S_.+$'</code> |
| `TYPES_PATTERN` | `Integer / String` | <code>'^TY_.+$'</code> |
| `MACRO_PATTERN` | `Integer / String` | <code>'^_.+$'</code> |
| `FORM_PATTERN` | `Integer / String` | <code>'^F_.+$'</code> |
| `FUNCTION_PATTERN` | `Integer / String` | <code>'^Z.*$'</code> |
| `INTF_LOCAL` | `Integer / String` | <code>'^LIF_.+$'</code> |
| `INTF_GLOBAL` | `Integer / String` | <code>'^ZIF_.+$'</code> |
| `EVENT_NAME` | `Integer / String` | <code>'^[A-Z][A-Z0-9_]+$'</code> |
| `EVENT_HANDLER` | `Integer / String` | <code>'^ON_.+$'</code> |
| `TEST_METHOD` | `Integer / String` | <code>'^(TEST&#124;SHOULD)_.+$'</code> |
| `PROG_PATTERN` | `Integer / String` | <code>'^Z.+$'</code> |
| `FUGR_PATTERN` | `Integer / String` | <code>'^Z.+$'</code> |

## CLI & CI/CD Configuration

```yaml
checks:
  prefer-naming:
    enabled: true
    severity: warning
    attributes:
      attrIgnExc: true
      attrIgnLocal: true
      attrIgnIntf: false
      attrStatics: '^G._.+$'
      attrInstance: '^M._.+$'
      attrConstants: ''
      paramIgnExc: true
      paramImporting: '^I._.+$'
      paramReturning: '^R._.+$'
      paramChanging: '^C._.+$'
      paramExporting: '^E._.+$'
      localData: '^L._.+$'
      localConst: '^LC_.+$'
      localFs: '^<L._.+>$'
      localStatics: '^S._.+$'
      classLocal: '^LC(L|X)_.+$'
      classTest: '^LTCL_.+$'
      classGlobal: '^ZC(L|X)_.+$'
      sscrParam: '^P_.+$'
      sscrSelopt: '^S_.+$'
      typesPattern: '^TY_.+$'
      macroPattern: '^_.+$'
      formPattern: '^F_.+$'
      functionPattern: '^Z.*$'
      intfLocal: '^LIF_.+$'
      intfGlobal: '^ZIF_.+$'
      eventName: '^[A-Z][A-Z0-9_]+$'
      eventHandler: '^ON_.+$'
      testMethod: '^(TEST|SHOULD)_.+$'
      progPattern: '^Z.+$'
      fugrPattern: '^Z.+$'
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC NAMING

" SAP CI_ prefix format:
... "#EC CI_NAMING
```

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_NAMING`
* **Implementation File:** [zcl_skylint_pref_naming.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_naming.clas.abap)
