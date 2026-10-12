CLASS zcl_skylint_check_080 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        avoid_use TYPE if_ci_atc_check=>ty_finding_code VALUE 'AVOID_USE',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    DATA mv_check_default_key    TYPE abap_bool VALUE abap_true.
    DATA mv_check_break          TYPE abap_bool VALUE abap_true.
    DATA mv_check_statics        TYPE abap_bool VALUE abap_true.
    DATA mv_check_define         TYPE abap_bool VALUE abap_true.
    DATA mv_check_describe_lines TYPE abap_bool VALUE abap_true.
    DATA mv_check_test_seams     TYPE abap_bool VALUE abap_true.

ENDCLASS.


CLASS zcl_skylint_check_080 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid use of certain statements (BREAK, DEFAULT KEY, STATICS, DEFINE, etc.)'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code     = c_finding_codes-avoid_use
                       severity = if_ci_atc_check=>finding_severities-warning
                       text     = 'Avoid use of statement; use modern Clean ABAP construct instead' ) )
                 attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                              ( name  = 'CHECK_DEFAULT_KEY'
                                                value = REF #( mv_check_default_key ) )
                                              ( name  = 'CHECK_BREAK'
                                                value = REF #( mv_check_break ) )
                                              ( name  = 'CHECK_STATICS'
                                                value = REF #( mv_check_statics ) )
                                              ( name  = 'CHECK_DEFINE'
                                                value = REF #( mv_check_define ) )
                                              ( name  = 'CHECK_DESCRIBE_LINES'
                                                value = REF #( mv_check_describe_lines ) )
                                              ( name  = 'CHECK_TEST_SEAMS'
                                                value = REF #( mv_check_test_seams ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_check_default_key    TYPE abap_bool.
    DATA lv_check_break          TYPE abap_bool.
    DATA lv_check_statics        TYPE abap_bool.
    DATA lv_check_define         TYPE abap_bool.
    DATA lv_check_describe_lines TYPE abap_bool.
    DATA lv_check_test_seams     TYPE abap_bool.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    get_attribute( EXPORTING iv_name  = 'CHECK_DEFAULT_KEY'
                   IMPORTING ev_value = lv_check_default_key ).
    get_attribute( EXPORTING iv_name  = 'CHECK_BREAK'
                   IMPORTING ev_value = lv_check_break ).
    get_attribute( EXPORTING iv_name  = 'CHECK_STATICS'
                   IMPORTING ev_value = lv_check_statics ).
    get_attribute( EXPORTING iv_name  = 'CHECK_DEFINE'
                   IMPORTING ev_value = lv_check_define ).
    get_attribute( EXPORTING iv_name  = 'CHECK_DESCRIBE_LINES'
                   IMPORTING ev_value = lv_check_describe_lines ).
    get_attribute( EXPORTING iv_name  = 'CHECK_TEST_SEAMS'
                   IMPORTING ev_value = lv_check_test_seams ).

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF     lv_check_break = abap_true
         AND ( <ls_statement>-keyword = 'BREAK-POINT' OR <ls_statement>-keyword = 'BREAK' ).
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-avoid_use ).
        CONTINUE.
      ENDIF.

      IF lv_check_statics = abap_true AND <ls_statement>-keyword = 'STATICS'.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-avoid_use ).
        CONTINUE.
      ENDIF.

      IF lv_check_define = abap_true AND <ls_statement>-keyword = 'DEFINE'.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-avoid_use ).
        CONTINUE.
      ENDIF.

      IF     lv_check_test_seams = abap_true
         AND ( <ls_statement>-keyword = 'TEST-SEAM' OR <ls_statement>-keyword = 'TEST-INJECT' ).
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-avoid_use ).
        CONTINUE.
      ENDIF.

      IF     lv_check_describe_lines = abap_true
         AND <ls_statement>-keyword  = 'DESCRIBE'
         AND (    zcl_skylint_ast_util=>match_token_sequence( is_statement   = <ls_statement>
                                                              it_expected    = VALUE #( ( `TABLE` ) ( `LINES` ) )
                                                              iv_start_index = 2 ) = abap_true
               OR (     zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                                iv_index     = 2
                                                                iv_expected  = `TABLE` )      = abap_true
                    AND zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                                iv_lexeme    = `LINES` )      = abap_true ) ).
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-avoid_use ).
        CONTINUE.
      ENDIF.

      IF     lv_check_default_key = abap_true
         AND zcl_skylint_ast_util=>find_token_sequence( is_statement = <ls_statement>
                                                        it_expected  = VALUE #( ( `DEFAULT` ) ( `KEY` ) ) ) > 0.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-avoid_use ).
        CONTINUE.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
