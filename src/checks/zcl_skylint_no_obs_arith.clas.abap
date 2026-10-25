CLASS zcl_skylint_no_obs_arith DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        obsolete_arithmetic TYPE if_ci_atc_check=>ty_finding_code VALUE 'OBS_ARITH',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        replace_arithmetic TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'REPLACE_AR',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'OBSOLETE_ARITH'.

    DATA mv_check_add      TYPE abap_bool VALUE abap_true.
    DATA mv_check_add_corr TYPE abap_bool VALUE abap_true.
    DATA mv_check_compute  TYPE abap_bool VALUE abap_true.
    DATA mv_check_move     TYPE abap_bool VALUE abap_true.
    DATA mv_check_get_ref  TYPE abap_bool VALUE abap_true.

    METHODS build_arithmetic_line
      IMPORTING is_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_line) TYPE string.

ENDCLASS.


CLASS zcl_skylint_no_obs_arith IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'skylint: Obsolete Arithmetic and Assignment Statements'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-obsolete_arithmetic
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid obsolete arithmetic or assignment statements; use =, +, -, *, /'
                       pseudo_comment = c_pseudo_comment ) )
                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-replace_arithmetic
                                                short_text = 'Replace with modern assignment or operator' ) )
                 attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                              ( name  = 'CHECK_ADD'
                                                value = REF #( mv_check_add ) )
                                              ( name  = 'CHECK_ADD_CORR'
                                                value = REF #( mv_check_add_corr ) )
                                              ( name  = 'CHECK_COMPUTE'
                                                value = REF #( mv_check_compute ) )
                                              ( name  = 'CHECK_MOVE'
                                                value = REF #( mv_check_move ) )
                                              ( name  = 'CHECK_GET_REF'
                                                value = REF #( mv_check_get_ref ) ) ) ) ).
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
      CLEAR: ls_quickfix,
             lv_line.

      CASE <ls_statement>-keyword.
        WHEN 'ADD' OR 'SUBTRACT' OR 'MULTIPLY' OR 'DIVIDE'.
          IF mv_check_add = abap_true.
            lv_line = build_arithmetic_line( <ls_statement> ).
            IF lv_line IS NOT INITIAL.
              ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-replace_arithmetic
                                              iv_statement_from = lv_stmt_idx
                                              it_new_code       = VALUE #( ( lv_line ) ) ).
            ENDIF.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-obsolete_arithmetic
                              is_quickfix     = ls_quickfix ).
          ENDIF.

        WHEN 'ADD-CORRESPONDING' OR 'SUBTRACT-CORRESPONDING'
          OR 'MULTIPLY-CORRESPONDING' OR 'DIVIDE-CORRESPONDING'.
          IF mv_check_add_corr = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-obsolete_arithmetic ).
          ENDIF.

        WHEN 'COMPUTE'.
          IF     mv_check_compute = abap_true
             AND zcl_skylint_ast_util=>find_token( is_statement = <ls_statement>
                                                   iv_lexeme    = 'COMPUTE' )    > 0.
            lv_line = condense( zcl_skylint_ast_util=>flatten_statement( is_statement = <ls_statement>
                                                                         it_deletions = VALUE #( ( 1 ) )
                                                                         iv_suffix    = '.' ) ).
            IF lv_line IS NOT INITIAL.
              ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-replace_arithmetic
                                              iv_statement_from = lv_stmt_idx
                                              it_new_code       = VALUE #( ( lv_line ) ) ).
            ENDIF.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-obsolete_arithmetic
                              is_quickfix     = ls_quickfix ).
          ENDIF.

        WHEN 'MOVE'.
          IF mv_check_move = abap_true.
            IF zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                       iv_lexeme    = 'TO' ) = abap_true.
              lv_src = zcl_skylint_ast_util=>get_token_after( is_statement = <ls_statement>
                                                              iv_lexeme    = 'MOVE' )-lexeme.
              lv_dst = zcl_skylint_ast_util=>get_token_after( is_statement = <ls_statement>
                                                              iv_lexeme    = 'TO' )-lexeme.
              IF lv_src IS NOT INITIAL AND lv_dst IS NOT INITIAL.
                lv_line = |{ lv_dst } = { lv_src }.|.
                ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-replace_arithmetic
                                                iv_statement_from = lv_stmt_idx
                                                it_new_code       = VALUE #( ( lv_line ) ) ).
              ENDIF.
            ENDIF.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-obsolete_arithmetic
                              is_quickfix     = ls_quickfix ).
          ENDIF.

        WHEN 'GET'.
          IF     mv_check_get_ref = abap_true
             AND zcl_skylint_ast_util=>find_token_sequence( is_statement = <ls_statement>
                                                            it_expected  = VALUE #( ( `REFERENCE` ) ( `OF` ) ) ) > 0
             AND zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                         iv_lexeme    = 'INTO' ) = abap_true.
            lv_src = zcl_skylint_ast_util=>get_token_after( is_statement = <ls_statement>
                                                            iv_lexeme    = 'OF' )-lexeme.
            lv_dst = zcl_skylint_ast_util=>get_token_after( is_statement = <ls_statement>
                                                            iv_lexeme    = 'INTO' )-lexeme.
            IF lv_src IS NOT INITIAL AND lv_dst IS NOT INITIAL.
              lv_line = |{ lv_dst } = REF #( { lv_src } ).|.
              ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-replace_arithmetic
                                              iv_statement_from = lv_stmt_idx
                                              it_new_code       = VALUE #( ( lv_line ) ) ).
            ENDIF.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-obsolete_arithmetic
                              is_quickfix     = ls_quickfix ).
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD build_arithmetic_line.
    DATA lv_src TYPE string.
    DATA lv_dst TYPE string.
    DATA lv_op  TYPE string.
    DATA lv_kw  TYPE string.

    CLEAR rv_line.
    lv_kw = is_statement-keyword.

    CASE lv_kw.
      WHEN 'ADD'.
        lv_src = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                        iv_lexeme    = 'ADD' )-lexeme.
        lv_dst = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                        iv_lexeme    = 'TO' )-lexeme.
        lv_op = '+'.
      WHEN 'SUBTRACT'.
        lv_src = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                        iv_lexeme    = 'SUBTRACT' )-lexeme.
        lv_dst = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                        iv_lexeme    = 'FROM' )-lexeme.
        lv_op = '-'.
      WHEN 'MULTIPLY'.
        lv_dst = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                        iv_lexeme    = 'MULTIPLY' )-lexeme.
        lv_src = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                        iv_lexeme    = 'BY' )-lexeme.
        lv_op = '*'.
      WHEN 'DIVIDE'.
        lv_dst = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                        iv_lexeme    = 'DIVIDE' )-lexeme.
        lv_src = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                        iv_lexeme    = 'BY' )-lexeme.
        lv_op = '/'.
    ENDCASE.

    IF lv_src IS NOT INITIAL AND lv_dst IS NOT INITIAL AND lv_op IS NOT INITIAL.
      rv_line = |{ lv_dst } = { lv_dst } { lv_op } { lv_src }.|.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
