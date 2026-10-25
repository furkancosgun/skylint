CLASS zcl_skylint_no_obs_control DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        obsolete_control TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_OBS_CTR',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_OBS_CONTROL'.

    DATA mv_check_form           TYPE abap_bool VALUE abap_true.
    DATA mv_check_loop_ctl       TYPE abap_bool VALUE abap_true.
    DATA mv_check_break          TYPE abap_bool VALUE abap_true.
    DATA mv_check_define         TYPE abap_bool VALUE abap_true.
    DATA mv_check_test_seams     TYPE abap_bool VALUE abap_true.
    DATA mv_check_catch_system   TYPE abap_bool VALUE abap_true.
    DATA mv_check_set_ext_check  TYPE abap_bool VALUE abap_true.
    DATA mv_check_select_no_into TYPE abap_bool VALUE abap_true.
    DATA mv_check_exit_sql       TYPE abap_bool VALUE abap_true.
    DATA mv_check_sort_by_fs     TYPE abap_bool VALUE abap_true.

    METHODS select_without_into
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_is) TYPE abap_bool.

    METHODS select_is_count_star
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_is) TYPE abap_bool.

    METHODS sort_by_field_symbol
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_is) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_no_obs_control IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Obsolete Control Flow and Procedural Statements'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-obsolete_control
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid obsolete control flow (FORM, AT NEW, BREAK, DEFINE, etc.)'
                       pseudo_comment = c_pseudo_comment ) )
                 attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                              ( name  = 'CHECK_FORM'
                                                value = REF #( mv_check_form ) )
                                              ( name  = 'CHECK_LOOP_CTL'
                                                value = REF #( mv_check_loop_ctl ) )
                                              ( name  = 'CHECK_BREAK'
                                                value = REF #( mv_check_break ) )
                                              ( name  = 'CHECK_DEFINE'
                                                value = REF #( mv_check_define ) )
                                              ( name  = 'CHECK_TEST_SEAMS'
                                                value = REF #( mv_check_test_seams ) )
                                              ( name  = 'CHECK_CATCH_SYSTEM'
                                                value = REF #( mv_check_catch_system ) )
                                              ( name  = 'CHECK_SET_EXT_CHECK'
                                                value = REF #( mv_check_set_ext_check ) )
                                              ( name  = 'CHECK_SELECT_NO_INTO'
                                                value = REF #( mv_check_select_no_into ) )
                                              ( name  = 'CHECK_EXIT_SQL'
                                                value = REF #( mv_check_exit_sql ) )
                                              ( name  = 'CHECK_SORT_BY_FS'
                                                value = REF #( mv_check_sort_by_fs ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'PERFORM' OR 'FORM'.
          IF mv_check_form = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-obsolete_control ).
          ENDIF.

        WHEN 'BREAK-POINT' OR 'BREAK'.
          IF mv_check_break = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-obsolete_control ).
          ENDIF.

        WHEN 'DEFINE'.
          IF mv_check_define = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-obsolete_control ).
          ENDIF.

        WHEN 'TEST-SEAM' OR 'TEST-INJECT'.
          IF mv_check_test_seams = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-obsolete_control ).
          ENDIF.

        WHEN 'SUM'.
          IF mv_check_loop_ctl = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-obsolete_control ).
          ENDIF.

        WHEN 'ON'.
          IF     mv_check_loop_ctl = abap_true
             AND zcl_skylint_ast_util=>find_token( is_statement = <ls_statement>
                                                   iv_lexeme    = 'CHANGE' )     > 0.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-obsolete_control ).
          ENDIF.

        WHEN 'AT'.
          IF     mv_check_loop_ctl = abap_true
             AND (    zcl_skylint_ast_util=>find_token( is_statement = <ls_statement>
                                                        iv_lexeme    = 'NEW' )        > 0
                   OR zcl_skylint_ast_util=>find_token( is_statement = <ls_statement>
                                                        iv_lexeme    = 'END' )        > 0
                   OR zcl_skylint_ast_util=>find_token( is_statement = <ls_statement>
                                                        iv_lexeme    = 'FIRST' )      > 0
                   OR zcl_skylint_ast_util=>find_token( is_statement = <ls_statement>
                                                        iv_lexeme    = 'LAST' )       > 0 ).
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-obsolete_control ).
          ENDIF.

        WHEN 'CATCH'.
          IF     mv_check_catch_system = abap_true
             AND zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                         iv_lexeme    = 'SYSTEM-EXCEPTIONS' ) = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-obsolete_control ).
          ENDIF.

        WHEN 'SET'.
          IF     mv_check_set_ext_check = abap_true
             AND zcl_skylint_ast_util=>find_token_sequence( is_statement = <ls_statement>
                                                            it_expected  = VALUE #( ( `EXTENDED` ) ( `CHECK` ) ) ) > 0.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-obsolete_control ).
          ENDIF.

        WHEN 'EXIT'.
          IF     mv_check_exit_sql = abap_true
             AND zcl_skylint_ast_util=>find_token_sequence( is_statement = <ls_statement>
                                                            it_expected  = VALUE #( ( `FROM` ) ( `SQL` ) ) ) > 0.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-obsolete_control ).
          ENDIF.

        WHEN 'SORT'.
          IF     mv_check_sort_by_fs                    = abap_true
             AND sort_by_field_symbol( <ls_statement> ) = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-obsolete_control ).
          ENDIF.

        WHEN 'SELECT'.
          IF     mv_check_select_no_into               = abap_true
             AND select_without_into( <ls_statement> ) = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-obsolete_control ).
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD select_without_into.
    rv_is = abap_false.

    IF    zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                  iv_lexeme    = 'INTO' )      = abap_true
       OR zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                  iv_lexeme    = 'APPENDING' ) = abap_true.
      RETURN.
    ENDIF.

    IF select_is_count_star( is_statement ) = abap_true.
      RETURN.
    ENDIF.

    rv_is = abap_true.
  ENDMETHOD.

  METHOD select_is_count_star.
    DATA lv_lexeme TYPE string.
    DATA lv_next   TYPE string.
    DATA lv_next2  TYPE string.
    DATA lv_index  TYPE i.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_is = abap_false.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      lv_lexeme = <ls_token>-lexeme.
      IF strlen( lv_lexeme ) < 6 OR lv_lexeme(6) <> 'COUNT('.
        CONTINUE.
      ENDIF.
      IF    lv_lexeme(1) = ''''
         OR lv_lexeme(1) = '`'
         OR lv_lexeme(1) = '|'.
        CONTINUE.
      ENDIF.
      IF contains( val = lv_lexeme
                   sub = '*' ).
        rv_is = abap_true.
        RETURN.
      ENDIF.
      lv_index = sy-tabix.
      lv_next  = zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                         iv_index     = lv_index + 1 ).
      lv_next2 = zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                         iv_index     = lv_index + 2 ).
      IF lv_next = '*' AND lv_next2 = ')'.
        rv_is = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD sort_by_field_symbol.
    DATA lv_index  TYPE i.
    DATA lv_lexeme TYPE string.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_is = abap_false.
    lv_index = zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                 iv_lexeme    = 'BY' ).
    IF lv_index = 0.
      RETURN.
    ENDIF.

    lv_index += 1.
    LOOP AT is_statement-tokens ASSIGNING <ls_token> FROM lv_index.
      lv_lexeme = <ls_token>-lexeme.
      IF strlen( lv_lexeme ) >= 2 AND lv_lexeme(1) = '<'.
        rv_is = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
