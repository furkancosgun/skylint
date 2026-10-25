---
title: "Prefer Modern Class-Based APIs over Obsolete Function Modules"
description: "Prefer Modern Class-Based APIs over Obsolete Function Modules - Clean ABAP guidelines, modern SAP syntax rules, and automated ATC code inspection for SAP S/4HANA and ABAP Cloud."
keywords: "Clean ABAP, SAP ATC Check, ABAP Cloud, S/4HANA Readiness, pref-func-module, clean-abap"
category: "clean-abap"
ruleId: "pref-func-module"
---

# Prefer Modern Class-Based APIs over Obsolete Function Modules

<div style="margin-top: 1rem; margin-bottom: 1.5rem; display: flex; gap: 0.5rem; flex-wrap: wrap;">
  <Badge type="warning" text="Warning" />
  <Badge type="tip" text="Clean ABAP & Modern Syntax" />
  <Badge type="danger" text="#EC PREF_FUNC_MOD" />
  <Badge type="info" text="Remote Enabled" />
</div>

## Overview

Prefer class-based APIs over obsolete function modules.

> **ATC Finding Message:** `Legacy function &1 is obsolete; migrate to &2`

## Rationale

Classic function modules are non-object-oriented procedural constructs. Modern ABAP provides robust, object-oriented class libraries (such as CL_SYSTEM_UUID, CL_ABAP_TSTMP, CL_ABAP_MESSAGE_DIGEST, and CL_BCS) that improve testability, type safety, and ABAP Cloud compatibility. Prefer recommended class-based APIs over obsolete function modules.

### Non-Compliant

```abap
CALL FUNCTION 'GUID_CREATE'
  IMPORTING
    ev_guid_32 = lv_guid.
```

### Compliant

```abap
lv_guid = cl_system_uuid=>create_uuid_c32_static( ).
```

## Suppression

To suppress findings for this rule, append the pseudo-comment to the statement:

```abap
" Standard pseudo-comment:
... "#EC PREF_FUNC_MOD

" SAP CI_ prefix format:
... "#EC CI_PREF_FUNC_MOD
```

## Recommended Replacements Reference

The following table lists all 67 obsolete classic function modules detected by this rule along with their recommended modern replacements:

| Obsolete Function Module | Modern Recommended Replacement |
|---|---|
| `CALCULATE_HASH_FOR_CHAR` | `CL_ABAP_MESSAGE_DIGEST` |
| `CALCULATE_HASH_FOR_RAW` | `CL_ABAP_HMAC` or `CL_ABAP_MESSAGE_DIGEST` |
| `CCU_TIMESTAMP_DIFFERENCE` | `CL_ABAP_TSTMP` |
| `CLPB_EXPORT` | `CL_GUI_FRONTEND_SERVICES` |
| `CLPB_IMPORT` | `CL_GUI_FRONTEND_SERVICES` |
| `CONVERT_DATE_TO_EXTERNAL` | `CL_ABAP_DATFM` |
| `CONVERT_TIME_INPUT` | `CL_ABAP_TIMEFM` |
| `DOWNLOAD` | `CL_GUI_FRONTEND_SERVICES` |
| `ECATT_CONV_XSTRING_TO_STRING` | `CL_BINARY_CONVERT` |
| `F4_FILENAME` | `CL_GUI_FRONTEND_SERVICES` |
| `FUNCTION_EXISTS` | `TRY..CATCH cx_sy_dyn_call_illegal_func` |
| `GUI_CREATE_DIRECTORY` | `CL_GUI_FRONTEND_SERVICES` |
| `GUI_DELETE_FILE` | `CL_GUI_FRONTEND_SERVICES` |
| `GUI_DOWNLOAD` | `CL_GUI_FRONTEND_SERVICES` |
| `GUI_EXEC` | `CL_GUI_FRONTEND_SERVICES` |
| `GUI_FB_USAGE` | `CL_GUI_FRONTEND_SERVICES` |
| `GUI_FILE_LOAD_DIALOG` | `CL_GUI_FRONTEND_SERVICES` |
| `GUI_FILE_SAVE_DIALOG` | `CL_GUI_FRONTEND_SERVICES` |
| `GUI_GET_DESKTOP_INFO` | `CL_GUI_FRONTEND_SERVICES` |
| `GUI_GET_FILE_INFO` | `CL_GUI_FRONTEND_SERVICES` |
| `GUI_GET_REGVALUE` | `CL_GUI_FRONTEND_SERVICES` |
| `GUI_MULTIPLE_FILE_LOAD_DIALOG` | `CL_GUI_FRONTEND_SERVICES` |
| `GUI_REMOVE_DIRECTORY` | `CL_GUI_FRONTEND_SERVICES` |
| `GUI_RUN` | `CL_GUI_FRONTEND_SERVICES` |
| `GUI_SET_REGVALUE` | `CL_GUI_FRONTEND_SERVICES` |
| `GUI_UPLOAD` | `CL_GUI_FRONTEND_SERVICES` |
| `GUI_VSS_DOWNLOAD` | `CL_GUI_FRONTEND_SERVICES` |
| `GUI_VSS_UPLOAD` | `CL_GUI_FRONTEND_SERVICES` |
| `GUID_CREATE` | `CL_SYSTEM_UUID` |
| `IGN_TIMESTAMP_DIFFERENCE` | `CL_ABAP_TSTMP` |
| `IGN_TIMESTAMP_PLUSMINUS` | `CL_ABAP_TSTMP` |
| `ISM_SD_GET_PRICING_CONDITIONS` | `CL_PRC_RESULT_FACTORY (SAP Note 2220005)` |
| `JOB_CREATE` | `CL_BP_ABAP_JOB` |
| `JOB_SUBMIT` | `CL_BP_ABAP_JOB` |
| `MD5_CALCULATE_HASH_FOR_CHAR` | `CL_ABAP_MESSAGE_DIGEST` |
| `MD5_CALCULATE_HASH_FOR_RAW` | `CL_ABAP_MESSAGE_DIGEST` |
| `POPUP_TO_CONFIRM_LOSS_OF_DATA` | `POPUP_TO_CONFIRM` |
| `POPUP_TO_CONFIRM_STEP` | `POPUP_TO_CONFIRM` |
| `POPUP_TO_CONFIRM_WITH_MESSAGE` | `POPUP_TO_CONFIRM` |
| `POPUP_TO_CONFIRM_WITH_VALUE` | `POPUP_TO_CONFIRM` |
| `POPUP_TO_CONFIRM_WITH_VALUE_2` | `POPUP_TO_CONFIRM` |
| `POPUP_TO_DECIDE` | `POPUP_TO_CONFIRM` |
| `POPUP_TO_DECIDE_INFO` | `POPUP_TO_CONFIRM` |
| `POPUP_TO_DECIDE_WITH_MESSAGE` | `POPUP_TO_CONFIRM` |
| `POPUP_TO_GET_VALUE` | `POPUP_GET_VALUES` |
| `QF05_RANDOM_INTEGER` | `CL_ABAP_RANDOM_INT` |
| `REGISTRY_GET` | `CL_GUI_FRONTEND_SERVICES` |
| `REGISTRY_SET` | `CL_GUI_FRONTEND_SERVICES` |
| `REUSE_ALV_GRID_DISPLAY` | `CL_SALV_TABLE=>FACTORY or CL_GUI_ALV_GRID` |
| `ROUND` | `built-in function round( )` |
| `SAPGUI_PROGRESS_INDICATOR` | `CL_PROGRESS_INDICATOR` |
| `SCMS_BASE64_DECODE_STR` | `CL_HTTP_UTILITY` |
| `SCMS_STRING_TO_XSTRING` | `CL_BINARY_CONVERT` |
| `SO_NEW_DOCUMENT_ATT_SEND_API1` | `CL_BCS` |
| `SSFC_BASE64_DECODE` | `CL_HTTP_UTILITY` |
| `SSFC_BASE64_ENCODE` | `CL_HTTP_UTILITY` |
| `SUBST_GET_FILE_LIST` | `SAP Note 1686357` |
| `SYSTEM_GET_UNIQUE_ID` | `CL_SYSTEM_UUID` |
| `SYSTEM_UUID_C_CREATE` | `CL_SYSTEM_UUID` |
| `UPLOAD` | `CL_GUI_FRONTEND_SERVICES` |
| `WS_DOWNLOAD` | `CL_GUI_FRONTEND_SERVICES` |
| `WS_EXECUTE` | `CL_GUI_FRONTEND_SERVICES` |
| `WS_FILENAME_GET` | `CL_GUI_FRONTEND_SERVICES` |
| `WS_FILE_ATTRIB` | `CL_GUI_FRONTEND_SERVICES` |
| `WS_FILE_COPY` | `CL_GUI_FRONTEND_SERVICES` |
| `WS_FILE_DELETE` | `CL_GUI_FRONTEND_SERVICES` |
| `WS_QUERY` | `CL_GUI_FRONTEND_SERVICES` |
| `WS_UPLOAD` | `CL_GUI_FRONTEND_SERVICES` |


## Related Rules

* [Avoid Obsolete CALL METHOD](/rules/no-call-method) — <code>#EC NO_CALL_METHOD</code>
* [Prefer Class-Based Exceptions over Classic EXCEPTIONS](/rules/pref-class-exc) — <code>#EC PREF_CLASS_EXC</code>
* [Avoid Obsolete Control Flow and Procedural Forms](/rules/no-obs-control) — <code>#EC NO_OBS_CONTROL</code>

## Technical Details

* **Native ATC Class:** `ZCL_SKYLINT_PREF_FUNC_MODULE`
* **Implementation File:** [zcl_skylint_pref_func_module.clas.abap](https://github.com/furkancosgun/skylint/blob/main/src/checks/zcl_skylint_pref_func_module.clas.abap)
