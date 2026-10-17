CLASS zcl_skylint_no_obsolete DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        obsolete_statement TYPE if_ci_atc_check=>ty_finding_code VALUE 'OBSOLETE',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        replace_obsolete TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'REPLACE_OB',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'OBSOLETE'.

    DATA mv_check_move          TYPE abap_bool VALUE abap_true.
    DATA mv_check_refresh       TYPE abap_bool VALUE abap_true.
    DATA mv_check_compute       TYPE abap_bool VALUE abap_true.
    DATA mv_check_tables        TYPE abap_bool VALUE abap_true.
    DATA mv_check_field_groups  TYPE abap_bool VALUE abap_true.
    DATA mv_check_test_seams    TYPE abap_bool VALUE abap_true.
    DATA mv_check_break         TYPE abap_bool VALUE abap_true.
    DATA mv_check_statics       TYPE abap_bool VALUE abap_true.
    DATA mv_check_define        TYPE abap_bool VALUE abap_true.
    DATA mv_check_export_memory TYPE abap_bool VALUE abap_true.

ENDCLASS.


CLASS zcl_skylint_no_obsolete IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid obsolete or deprecated statements (MOVE, REFRESH, BREAK, STATICS, etc.)'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-obsolete_statement
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid obsolete or deprecated statement; use modern Clean ABAP construct'
                       pseudo_comment = c_pseudo_comment ) )
                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-replace_obsolete
                                                short_text = 'Replace obsolete statement' ) )
                 attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                              ( name  = 'CHECK_MOVE'
                                                value = REF #( mv_check_move ) )
                                              ( name  = 'CHECK_REFRESH'
                                                value = REF #( mv_check_refresh ) )
                                              ( name  = 'CHECK_COMPUTE'
                                                value = REF #( mv_check_compute ) )
                                              ( name  = 'CHECK_TABLES'
                                                value = REF #( mv_check_tables ) )
                                              ( name  = 'CHECK_FIELD_GROUPS'
                                                value = REF #( mv_check_field_groups ) )
                                              ( name  = 'CHECK_TEST_SEAMS'
                                                value = REF #( mv_check_test_seams ) )
                                              ( name  = 'CHECK_BREAK'
                                                value = REF #( mv_check_break ) )
                                              ( name  = 'CHECK_STATICS'
                                                value = REF #( mv_check_statics ) )
                                              ( name  = 'CHECK_DEFINE'
                                                value = REF #( mv_check_define ) )
                                              ( name  = 'CHECK_EXPORT_MEMORY'
                                                value = REF #( mv_check_export_memory ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx TYPE i.
    DATA lv_line     TYPE string.
    DATA lv_src      TYPE string.
    DATA lv_dst      TYPE string.
    DATA ls_quickfix TYPE zcl_skylint_check_base=>ty_quickfix.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_stmt_idx = sy-tabix.
      CLEAR ls_quickfix.
      CLEAR lv_line.

      CASE <ls_statement>-keyword.
        WHEN 'MOVE'.
          IF mv_check_move = abap_false.
            CONTINUE.
          ENDIF.
          IF     zcl_skylint_ast_util=>token_count( <ls_statement> )                   = 4
             AND zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                         iv_index     = 3
                                                         iv_expected  = `TO` )         = abap_true.
            lv_src = zcl_skylint_ast_util=>get_token_lexeme( is_statement = <ls_statement>
                                                             iv_index     = 2 ).
            lv_dst = zcl_skylint_ast_util=>get_token_lexeme( is_statement = <ls_statement>
                                                             iv_index     = 4 ).
            lv_line = |{ lv_dst } = { lv_src }.|.
          ENDIF.

        WHEN 'REFRESH'.
          IF mv_check_refresh = abap_false.
            CONTINUE.
          ENDIF.
          IF zcl_skylint_ast_util=>token_count( <ls_statement> ) = 2.
            lv_dst = zcl_skylint_ast_util=>get_token_lexeme( is_statement = <ls_statement>
                                                             iv_index     = 2 ).
            lv_line = |CLEAR { lv_dst }.|.
          ENDIF.

        WHEN 'COMPUTE'.
          IF mv_check_compute = abap_false.
            CONTINUE.
          ENDIF.
          IF zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                     iv_index     = 1
                                                     iv_expected  = `COMPUTE` ) = abap_true.
            lv_line = condense( zcl_skylint_ast_util=>flatten_statement( is_statement = <ls_statement>
                                                                         it_deletions = VALUE #( ( 1 ) )
                                                                         iv_suffix    = '.' ) ).
          ELSE.
            CONTINUE.
          ENDIF.

        WHEN 'TABLES'.
          IF mv_check_tables = abap_false.
            CONTINUE.
          ENDIF.

        WHEN 'FIELD-GROUPS'.
          IF mv_check_field_groups = abap_false.
            CONTINUE.
          ENDIF.

        WHEN 'TEST-SEAM' OR 'TEST-INJECT'.
          IF mv_check_test_seams = abap_false.
            CONTINUE.
          ENDIF.

        WHEN 'BREAK-POINT' OR 'BREAK'.
          IF mv_check_break = abap_false.
            CONTINUE.
          ENDIF.

        WHEN 'STATICS'.
          IF mv_check_statics = abap_false.
            CONTINUE.
          ENDIF.

        WHEN 'DEFINE'.
          IF mv_check_define = abap_false.
            CONTINUE.
          ENDIF.

        WHEN 'EXPORT'.
          IF mv_check_export_memory = abap_false.
            CONTINUE.
          ENDIF.
          IF     zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                         iv_lexeme    = 'MEMORY' )     = abap_false
             AND zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                         iv_lexeme    = 'DATABASE' )   = abap_false.
            CONTINUE.
          ENDIF.

        WHEN OTHERS.
          CONTINUE.
      ENDCASE.

      IF lv_line IS NOT INITIAL.
        ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-replace_obsolete
                                        iv_statement_from = lv_stmt_idx
                                        it_new_code       = VALUE #( ( lv_line ) ) ).
      ENDIF.

      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-obsolete_statement
                        is_quickfix     = ls_quickfix ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
