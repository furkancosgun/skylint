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

    TYPES ty_function_names TYPE HASHED TABLE OF string WITH UNIQUE KEY table_line.

    DATA mt_forbidden_fms TYPE ty_function_names.

    METHODS init_function_names.

    METHODS extract_function_name
      IMPORTING is_token       TYPE if_ci_atc_source_code_provider=>ty_token
      RETURNING VALUE(rv_name) TYPE string.

ENDCLASS.


CLASS zcl_skylint_pref_func_module IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Prefer class-based APIs over obsolete function modules'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-recommendation
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Use modern class-based API instead of obsolete function module'
                       pseudo_comment = c_pseudo_comment ) ) ) ).

    init_function_names( ).
  ENDMETHOD.

  METHOD check.
    DATA ls_func_tok TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_name     TYPE string.
    FIELD-SYMBOLS <ls_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_stmt>.
      IF <ls_stmt>-keyword <> 'CALL'.
        CONTINUE.
      ENDIF.

      IF zcl_skylint_ast_util=>match_token_sequence(
             is_statement = <ls_stmt>
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

      IF line_exists( mt_forbidden_fms[ table_line = lv_name ] ).
        report_token( is_statement    = <ls_stmt>
                      is_token        = ls_func_tok
                      iv_finding_code = c_finding_codes-recommendation ).
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

  METHOD init_function_names.
    mt_forbidden_fms = VALUE #(
        ( `CALCULATE_HASH_FOR_CHAR` )
        ( `CALCULATE_HASH_FOR_RAW` )
        ( `CCU_TIMESTAMP_DIFFERENCE` )
        ( `CLPB_EXPORT` )
        ( `CLPB_IMPORT` )
        ( `CONVERT_DATE_TO_EXTERNAL` )
        ( `CONVERT_TIME_INPUT` )
        ( `DOWNLOAD` )
        ( `ECATT_CONV_XSTRING_TO_STRING` )
        ( `F4_FILENAME` )
        ( `FUNCTION_EXISTS` )
        ( `GUI_CREATE_DIRECTORY` )
        ( `GUI_DELETE_FILE` )
        ( `GUI_DOWNLOAD` )
        ( `GUI_EXEC` )
        ( `GUI_FB_USAGE` )
        ( `GUI_FILE_LOAD_DIALOG` )
        ( `GUI_FILE_SAVE_DIALOG` )
        ( `GUI_GET_DESKTOP_INFO` )
        ( `GUI_GET_FILE_INFO` )
        ( `GUI_GET_REGVALUE` )
        ( `GUI_MULTIPLE_FILE_LOAD_DIALOG` )
        ( `GUI_REMOVE_DIRECTORY` )
        ( `GUI_RUN` )
        ( `GUI_SET_REGVALUE` )
        ( `GUI_UPLOAD` )
        ( `GUI_VSS_DOWNLOAD` )
        ( `GUI_VSS_UPLOAD` )
        ( `GUID_CREATE` )
        ( `IGN_TIMESTAMP_DIFFERENCE` )
        ( `IGN_TIMESTAMP_PLUSMINUS` )
        ( `ISM_SD_GET_PRICING_CONDITIONS` )
        ( `JOB_CREATE` )
        ( `JOB_SUBMIT` )
        ( `MD5_CALCULATE_HASH_FOR_CHAR` )
        ( `MD5_CALCULATE_HASH_FOR_RAW` )
        ( `POPUP_TO_CONFIRM_LOSS_OF_DATA` )
        ( `POPUP_TO_CONFIRM_STEP` )
        ( `POPUP_TO_CONFIRM_WITH_MESSAGE` )
        ( `POPUP_TO_CONFIRM_WITH_VALUE` )
        ( `POPUP_TO_CONFIRM_WITH_VALUE_2` )
        ( `POPUP_TO_DECIDE` )
        ( `POPUP_TO_DECIDE_INFO` )
        ( `POPUP_TO_DECIDE_WITH_MESSAGE` )
        ( `POPUP_TO_GET_VALUE` )
        ( `QF05_RANDOM_INTEGER` )
        ( `REGISTRY_GET` )
        ( `REGISTRY_SET` )
        ( `REUSE_ALV_GRID_DISPLAY` )
        ( `ROUND` )
        ( `SAPGUI_PROGRESS_INDICATOR` )
        ( `SCMS_BASE64_DECODE_STR` )
        ( `SCMS_STRING_TO_XSTRING` )
        ( `SO_NEW_DOCUMENT_ATT_SEND_API1` )
        ( `SSFC_BASE64_DECODE` )
        ( `SSFC_BASE64_ENCODE` )
        ( `SUBST_GET_FILE_LIST` )
        ( `SYSTEM_GET_UNIQUE_ID` )
        ( `SYSTEM_UUID_C_CREATE` )
        ( `UPLOAD` )
        ( `WS_DOWNLOAD` )
        ( `WS_EXECUTE` )
        ( `WS_FILENAME_GET` )
        ( `WS_FILE_ATTRIB` )
        ( `WS_FILE_COPY` )
        ( `WS_FILE_DELETE` )
        ( `WS_QUERY` )
        ( `WS_UPLOAD` ) ).
  ENDMETHOD.
ENDCLASS.
