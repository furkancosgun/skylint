CLASS zcl_skylint_pref_func_module DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        recommendation TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_FM',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_FUNC_MOD'.

    TYPES:
      BEGIN OF ty_recommendation,
        name    TYPE string,
        replace TYPE string,
      END OF ty_recommendation,
      ty_recommendations TYPE HASHED TABLE OF ty_recommendation WITH UNIQUE KEY name.

    DATA mt_recommendations TYPE ty_recommendations.

    METHODS init_recommendations.

    METHODS extract_function_name
      IMPORTING is_token       TYPE if_ci_atc_source_code_provider=>ty_token
      RETURNING VALUE(rv_name) TYPE string.

ENDCLASS.


CLASS zcl_skylint_pref_func_module IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Prefer class-based APIs over obsolete function modules'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-recommendation
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Legacy function &1 is obsolete; migrate to &2'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).

    init_recommendations( ).
  ENDMETHOD.

  METHOD check.
    DATA ls_func_tok TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_name     TYPE string.
    FIELD-SYMBOLS <ls_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_rec>  TYPE ty_recommendation.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_stmt>.
      IF <ls_stmt>-keyword <> 'CALL'.
        CONTINUE.
      ENDIF.

      IF zcl_skylint_ast_util=>match_token_sequence( is_statement = <ls_stmt>
                                                     it_expected  = VALUE #( ( `CALL` ) ( `FUNCTION` ) ) ) = abap_false.
        CONTINUE.
      ENDIF.

      ls_func_tok = zcl_skylint_ast_util=>get_token( is_statement = <ls_stmt>
                                                     iv_index     = 3 ).
      IF ls_func_tok-lexeme IS INITIAL.
        CONTINUE.
      ENDIF.

      lv_name = extract_function_name( ls_func_tok ).
      IF lv_name IS INITIAL.
        CONTINUE.
      ENDIF.

      ASSIGN mt_recommendations[ name = lv_name ] TO <ls_rec>.
      IF sy-subrc = 0.
        report_token( is_statement    = <ls_stmt>
                      is_token        = ls_func_tok
                      iv_finding_code = c_finding_codes-recommendation
                      is_parameters   = VALUE #( param_1 = lv_name
                                                 param_2 = <ls_rec>-replace ) ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD extract_function_name.
    DATA lv_raw   TYPE string.
    DATA lv_len   TYPE i.
    DATA lv_first TYPE c LENGTH 1.

    rv_name = ''.
    lv_raw = is_token-lexeme.
    lv_len = strlen( lv_raw ).

    IF lv_len < 2.
      RETURN.
    ENDIF.

    lv_first = substring( val = lv_raw
                          off = 0
                          len = 1 ).

    IF lv_first <> `'` AND lv_first <> '`'.
      RETURN.
    ENDIF.

    rv_name = to_upper( substring( val = lv_raw
                                   off = 1
                                   len = lv_len - 2 ) ).
  ENDMETHOD.

  METHOD init_recommendations.
    mt_recommendations = VALUE #(
        ( name = `CALCULATE_HASH_FOR_CHAR` replace = `CL_ABAP_MESSAGE_DIGEST` )
        ( name = `CALCULATE_HASH_FOR_RAW` replace = `CL_ABAP_HMAC or CL_ABAP_MESSAGE_DIGEST` )
        ( name = `CCU_TIMESTAMP_DIFFERENCE` replace = `CL_ABAP_TSTMP` )
        ( name = `CLPB_EXPORT` replace = `CL_GUI_FRONTEND_SERVICES` )
        ( name = `CLPB_IMPORT` replace = `CL_GUI_FRONTEND_SERVICES` )
        ( name = `CONVERT_DATE_TO_EXTERNAL` replace = `CL_ABAP_DATFM` )
        ( name = `CONVERT_TIME_INPUT` replace = `CL_ABAP_TIMEFM` )
        ( name = `DOWNLOAD` replace = `CL_GUI_FRONTEND_SERVICES` )
        ( name = `ECATT_CONV_XSTRING_TO_STRING` replace = `CL_BINARY_CONVERT` )
        ( name = `F4_FILENAME` replace = `CL_GUI_FRONTEND_SERVICES` )
        ( name = `FUNCTION_EXISTS` replace = `TRY..CATCH cx_sy_dyn_call_illegal_func` )
        ( name = `GUI_CREATE_DIRECTORY` replace = `CL_GUI_FRONTEND_SERVICES` )
        ( name = `GUI_DELETE_FILE` replace = `CL_GUI_FRONTEND_SERVICES` )
        ( name = `GUI_DOWNLOAD` replace = `CL_GUI_FRONTEND_SERVICES` )
        ( name = `GUI_EXEC` replace = `CL_GUI_FRONTEND_SERVICES` )
        ( name = `GUI_FB_USAGE` replace = `CL_GUI_FRONTEND_SERVICES` )
        ( name = `GUI_FILE_LOAD_DIALOG` replace = `CL_GUI_FRONTEND_SERVICES` )
        ( name = `GUI_FILE_SAVE_DIALOG` replace = `CL_GUI_FRONTEND_SERVICES` )
        ( name = `GUI_GET_DESKTOP_INFO` replace = `CL_GUI_FRONTEND_SERVICES` )
        ( name = `GUI_GET_FILE_INFO` replace = `CL_GUI_FRONTEND_SERVICES` )
        ( name = `GUI_GET_REGVALUE` replace = `CL_GUI_FRONTEND_SERVICES` )
        ( name = `GUI_MULTIPLE_FILE_LOAD_DIALOG` replace = `CL_GUI_FRONTEND_SERVICES` )
        ( name = `GUI_REMOVE_DIRECTORY` replace = `CL_GUI_FRONTEND_SERVICES` )
        ( name = `GUI_RUN` replace = `CL_GUI_FRONTEND_SERVICES` )
        ( name = `GUI_SET_REGVALUE` replace = `CL_GUI_FRONTEND_SERVICES` )
        ( name = `GUI_UPLOAD` replace = `CL_GUI_FRONTEND_SERVICES` )
        ( name = `GUI_VSS_DOWNLOAD` replace = `CL_GUI_FRONTEND_SERVICES` )
        ( name = `GUI_VSS_UPLOAD` replace = `CL_GUI_FRONTEND_SERVICES` )
        ( name = `GUID_CREATE` replace = `CL_SYSTEM_UUID` )
        ( name = `IGN_TIMESTAMP_DIFFERENCE` replace = `CL_ABAP_TSTMP` )
        ( name = `IGN_TIMESTAMP_PLUSMINUS` replace = `CL_ABAP_TSTMP` )
        ( name = `ISM_SD_GET_PRICING_CONDITIONS` replace = `CL_PRC_RESULT_FACTORY (SAP Note 2220005)` )
        ( name = `JOB_CREATE` replace = `CL_BP_ABAP_JOB` )
        ( name = `JOB_SUBMIT` replace = `CL_BP_ABAP_JOB` )
        ( name = `MD5_CALCULATE_HASH_FOR_CHAR` replace = `CL_ABAP_MESSAGE_DIGEST` )
        ( name = `MD5_CALCULATE_HASH_FOR_RAW` replace = `CL_ABAP_MESSAGE_DIGEST` )
        ( name = `POPUP_TO_CONFIRM_LOSS_OF_DATA` replace = `POPUP_TO_CONFIRM` )
        ( name = `POPUP_TO_CONFIRM_STEP` replace = `POPUP_TO_CONFIRM` )
        ( name = `POPUP_TO_CONFIRM_WITH_MESSAGE` replace = `POPUP_TO_CONFIRM` )
        ( name = `POPUP_TO_CONFIRM_WITH_VALUE` replace = `POPUP_TO_CONFIRM` )
        ( name = `POPUP_TO_CONFIRM_WITH_VALUE_2` replace = `POPUP_TO_CONFIRM` )
        ( name = `POPUP_TO_DECIDE` replace = `POPUP_TO_CONFIRM` )
        ( name = `POPUP_TO_DECIDE_INFO` replace = `POPUP_TO_CONFIRM` )
        ( name = `POPUP_TO_DECIDE_WITH_MESSAGE` replace = `POPUP_TO_CONFIRM` )
        ( name = `POPUP_TO_GET_VALUE` replace = `POPUP_GET_VALUES` )
        ( name = `QF05_RANDOM_INTEGER` replace = `CL_ABAP_RANDOM_INT` )
        ( name = `REGISTRY_GET` replace = `CL_GUI_FRONTEND_SERVICES` )
        ( name = `REGISTRY_SET` replace = `CL_GUI_FRONTEND_SERVICES` )
        ( name = `REUSE_ALV_GRID_DISPLAY` replace = `CL_SALV_TABLE=>FACTORY or CL_GUI_ALV_GRID` )
        ( name = `ROUND` replace = `built-in function round( )` )
        ( name = `SAPGUI_PROGRESS_INDICATOR` replace = `CL_PROGRESS_INDICATOR` )
        ( name = `SCMS_BASE64_DECODE_STR` replace = `CL_HTTP_UTILITY` )
        ( name = `SCMS_STRING_TO_XSTRING` replace = `CL_BINARY_CONVERT` )
        ( name = `SO_NEW_DOCUMENT_ATT_SEND_API1` replace = `CL_BCS` )
        ( name = `SSFC_BASE64_DECODE` replace = `CL_HTTP_UTILITY` )
        ( name = `SSFC_BASE64_ENCODE` replace = `CL_HTTP_UTILITY` )
        ( name = `SUBST_GET_FILE_LIST` replace = `SAP Note 1686357` )
        ( name = `SYSTEM_GET_UNIQUE_ID` replace = `CL_SYSTEM_UUID` )
        ( name = `SYSTEM_UUID_C_CREATE` replace = `CL_SYSTEM_UUID` )
        ( name = `UPLOAD` replace = `CL_GUI_FRONTEND_SERVICES` )
        ( name = `WS_DOWNLOAD` replace = `CL_GUI_FRONTEND_SERVICES` )
        ( name = `WS_EXECUTE` replace = `CL_GUI_FRONTEND_SERVICES` )
        ( name = `WS_FILENAME_GET` replace = `CL_GUI_FRONTEND_SERVICES` )
        ( name = `WS_FILE_ATTRIB` replace = `CL_GUI_FRONTEND_SERVICES` )
        ( name = `WS_FILE_COPY` replace = `CL_GUI_FRONTEND_SERVICES` )
        ( name = `WS_FILE_DELETE` replace = `CL_GUI_FRONTEND_SERVICES` )
        ( name = `WS_QUERY` replace = `CL_GUI_FRONTEND_SERVICES` )
        ( name = `WS_UPLOAD` replace = `CL_GUI_FRONTEND_SERVICES` ) ).
  ENDMETHOD.
ENDCLASS.
