# Enforce Naming Conventions

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="Finding: ATTR_NAME" />
</div>

## Overview

Standard Naming Conventions.

> **ATC Finding Message:** `Class attribute name does not match configured pattern`

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
| `ATTR_IGN_EXC` | `Boolean` | `true` |
| `ATTR_IGN_LOCAL` | `Boolean` | `true` |
| `ATTR_IGN_INTF` | `Boolean` | `false` |
| `ATTR_STATICS` | `Integer / String` | `'^G._.+$'` |
| `ATTR_INSTANCE` | `Integer / String` | `'^M._.+$'` |
| `ATTR_CONSTANTS` | `Integer / String` | `''` |
| `PARAM_IGN_EXC` | `Boolean` | `true` |
| `PARAM_IMPORTING` | `Integer / String` | `'^I._.+$'` |
| `PARAM_RETURNING` | `Integer / String` | `'^R._.+$'` |
| `PARAM_CHANGING` | `Integer / String` | `'^C._.+$'` |
| `PARAM_EXPORTING` | `Integer / String` | `'^E._.+$'` |
| `LOCAL_DATA` | `Integer / String` | `'^L._.+$'` |
| `LOCAL_CONST` | `Integer / String` | `'^LC_.+$'` |
| `LOCAL_FS` | `Integer / String` | `'^<L._.+>$'` |
| `LOCAL_STATICS` | `Integer / String` | `'^S._.+$'` |
| `CLASS_LOCAL` | `Integer / String` | `'^LC(L|X)_.+$'` |
| `CLASS_TEST` | `Integer / String` | `'^LTCL_.+$'` |
| `CLASS_GLOBAL` | `Integer / String` | `'^ZC(L|X)_.+$'` |
| `SSCR_PARAM` | `Integer / String` | `'^P_.+$'` |
| `SSCR_SELOPT` | `Integer / String` | `'^S_.+$'` |
| `TYPES_PATTERN` | `Integer / String` | `'^TY_.+$'` |
| `MACRO_PATTERN` | `Integer / String` | `'^_.+$'` |
| `FORM_PATTERN` | `Integer / String` | `'^F_.+$'` |
| `FUNCTION_PATTERN` | `Integer / String` | `'^Z.*$'` |
| `INTF_LOCAL` | `Integer / String` | `'^LIF_.+$'` |
| `INTF_GLOBAL` | `Integer / String` | `'^ZIF_.+$'` |
| `EVENT_NAME` | `Integer / String` | `'^[A-Z][A-Z0-9_]+$'` |
| `EVENT_HANDLER` | `Integer / String` | `'^ON_.+$'` |
| `TEST_METHOD` | `Integer / String` | `'^(TEST|SHOULD)_.+$'` |
| `PROG_PATTERN` | `Integer / String` | `'^Z.+$'` |
| `FUGR_PATTERN` | `Integer / String` | `'^Z.+$'` |

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
* **Finding Code:** `ATTR_NAME`
* **Implementation File:** [zcl_skylint_pref_naming.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_naming.clas.abap)
