# prefer-naming

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="Finding: ATTR_NAME" />
</div>

## Overview

Standard Naming Conventions.

> **ATC Finding Message:** `Class attribute name does not match configured pattern`

## Rationale

Standard Naming Conventions

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

| Parameter Name | Data Type | Default Value | Description |
|---|---|:---:|---|
| `ATTR_IGN_EXC` | `Boolean` | `true` | Configurable attribute for prefer-naming |
| `ATTR_IGN_LOCAL` | `Boolean` | `true` | Configurable attribute for prefer-naming |
| `ATTR_IGN_INTF` | `Boolean` | `false` | Configurable attribute for prefer-naming |
| `ATTR_STATICS` | `Integer / String` | `'^G` | Configurable attribute for prefer-naming |
| `ATTR_INSTANCE` | `Integer / String` | `'^M` | Configurable attribute for prefer-naming |
| `ATTR_CONSTANTS` | `Integer / String` | `''` | Configurable attribute for prefer-naming |
| `PARAM_IGN_EXC` | `Boolean` | `true` | Configurable attribute for prefer-naming |
| `PARAM_IMPORTING` | `Integer / String` | `'^I` | Configurable attribute for prefer-naming |
| `PARAM_RETURNING` | `Integer / String` | `'^R` | Configurable attribute for prefer-naming |
| `PARAM_CHANGING` | `Integer / String` | `'^C` | Configurable attribute for prefer-naming |
| `PARAM_EXPORTING` | `Integer / String` | `'^E` | Configurable attribute for prefer-naming |
| `LOCAL_DATA` | `Integer / String` | `'^L` | Configurable attribute for prefer-naming |
| `LOCAL_CONST` | `Integer / String` | `'^LC_` | Configurable attribute for prefer-naming |
| `LOCAL_FS` | `Integer / String` | `'^<L` | Configurable attribute for prefer-naming |
| `LOCAL_STATICS` | `Integer / String` | `'^S` | Configurable attribute for prefer-naming |
| `CLASS_LOCAL` | `Integer / String` | `'^LC(L|X)_` | Configurable attribute for prefer-naming |
| `CLASS_TEST` | `Integer / String` | `'^LTCL_` | Configurable attribute for prefer-naming |
| `CLASS_GLOBAL` | `Integer / String` | `'^ZC(L|X)_` | Configurable attribute for prefer-naming |
| `SSCR_PARAM` | `Integer / String` | `'^P_` | Configurable attribute for prefer-naming |
| `SSCR_SELOPT` | `Integer / String` | `'^S_` | Configurable attribute for prefer-naming |
| `TYPES_PATTERN` | `Integer / String` | `'^TY_` | Configurable attribute for prefer-naming |
| `MACRO_PATTERN` | `Integer / String` | `'^_` | Configurable attribute for prefer-naming |
| `FORM_PATTERN` | `Integer / String` | `'^F_` | Configurable attribute for prefer-naming |
| `FUNCTION_PATTERN` | `Integer / String` | `'^Z` | Configurable attribute for prefer-naming |
| `INTF_LOCAL` | `Integer / String` | `'^LIF_` | Configurable attribute for prefer-naming |
| `INTF_GLOBAL` | `Integer / String` | `'^ZIF_` | Configurable attribute for prefer-naming |
| `EVENT_NAME` | `Integer / String` | `'^[A-Z][A-Z0-9_]+$'` | Configurable attribute for prefer-naming |
| `EVENT_HANDLER` | `Integer / String` | `'^ON_` | Configurable attribute for prefer-naming |
| `TEST_METHOD` | `Integer / String` | `'^(TEST|SHOULD)_` | Configurable attribute for prefer-naming |
| `PROG_PATTERN` | `Integer / String` | `'^Z` | Configurable attribute for prefer-naming |
| `FUGR_PATTERN` | `Integer / String` | `'^Z` | Configurable attribute for prefer-naming |

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
      attrStatics: '^G
      attrInstance: '^M
      attrConstants: ''
      paramIgnExc: true
      paramImporting: '^I
      paramReturning: '^R
      paramChanging: '^C
      paramExporting: '^E
      localData: '^L
      localConst: '^LC_
      localFs: '^<L
      localStatics: '^S
      classLocal: '^LC(L|X)_
      classTest: '^LTCL_
      classGlobal: '^ZC(L|X)_
      sscrParam: '^P_
      sscrSelopt: '^S_
      typesPattern: '^TY_
      macroPattern: '^_
      formPattern: '^F_
      functionPattern: '^Z
      intfLocal: '^LIF_
      intfGlobal: '^ZIF_
      eventName: '^[A-Z][A-Z0-9_]+$'
      eventHandler: '^ON_
      testMethod: '^(TEST|SHOULD)_
      progPattern: '^Z
      fugrPattern: '^Z
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
