CLASS zcl_skylint_check_028 DEFINITION
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
    METHODS is_obsolete_keyword
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_028 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Avoid obsolete statements (MOVE, REFRESH, etc.)'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code     = c_finding_codes-obsolete_statement
                                       severity = if_ci_atc_check=>finding_severities-warning
                                       text     = 'Avoid obsolete statement; use modern expressions instead' ) )
                                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-replace_obsolete
                                                                short_text = 'Replace obsolete statement' ) ) ) ).
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

      IF is_obsolete_keyword( <ls_statement> ) = abap_false.
        CONTINUE.
      ENDIF.

      CASE <ls_statement>-keyword.
        WHEN 'MOVE'.
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
          IF zcl_skylint_ast_util=>token_count( <ls_statement> ) = 2.
            lv_dst = zcl_skylint_ast_util=>get_token_lexeme( is_statement = <ls_statement>
                                                             iv_index     = 2 ).
            lv_line = |CLEAR { lv_dst }.|.
          ENDIF.
        WHEN 'COMPUTE'.
          IF zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                     iv_index     = 1
                                                     iv_expected  = `COMPUTE` ) = abap_true.
            lv_line = condense( zcl_skylint_ast_util=>flatten_statement( is_statement = <ls_statement>
                                                                         it_deletions = VALUE #( ( 1 ) )
                                                                         iv_suffix    = '.' ) ).
          ENDIF.
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

  METHOD is_obsolete_keyword.
    rv_res = abap_false.

    CASE is_statement-keyword.
      WHEN 'MOVE' OR 'REFRESH' OR 'TEST-SEAM' OR 'TEST-INJECT' OR 'TABLES' OR 'FIELD-GROUPS'.
        rv_res = abap_true.
      WHEN 'COMPUTE'.
        IF zcl_skylint_ast_util=>matches_token_at( is_statement = is_statement
                                                   iv_index     = 1
                                                   iv_expected  = `COMPUTE` ) = abap_true.
          rv_res = abap_true.
        ENDIF.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
