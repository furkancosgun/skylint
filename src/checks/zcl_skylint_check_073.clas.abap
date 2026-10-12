CLASS zcl_skylint_check_073 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        calc_assign TYPE if_ci_atc_check=>ty_finding_code VALUE 'CALC_ASSGN',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        calc_assign TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'CALCASGN',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.
ENDCLASS.


CLASS zcl_skylint_check_073 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Prefer calculation assignment operators (+=, -=, *=, /=) over var = var + 1'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code     = c_finding_codes-calc_assign
                       severity = if_ci_atc_check=>finding_severities-warning
                       text     = 'Use calculation assignment operator (+=, -=) or ADD statement replacement' ) )
                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-calc_assign
                                                short_text = 'Use += style assignment' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_tok1     TYPE string.
    DATA lv_tok3     TYPE string.
    DATA lv_stmt_idx TYPE i.
    DATA lv_target   TYPE string.
    DATA lv_value    TYPE string.
    DATA lv_op       TYPE string.
    DATA lv_line     TYPE string.
    DATA ls_quickfix TYPE zcl_skylint_check_base=>ty_quickfix.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_stmt_idx = sy-tabix.
      CLEAR ls_quickfix.
      CLEAR lv_line.
      CASE <ls_statement>-keyword.
        WHEN 'ADD' OR 'SUBTRACT' OR 'MULTIPLY' OR 'DIVIDE'.
          IF zcl_skylint_ast_util=>token_count( <ls_statement> ) = 4
             AND (    zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                              iv_index     = 3
                                                              iv_expected  = `TO` ) = abap_true
                   OR zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                              iv_index     = 3
                                                              iv_expected  = `FROM` ) = abap_true ).
            lv_value = zcl_skylint_ast_util=>get_token_lexeme( is_statement = <ls_statement>
                                                               iv_index     = 2 ).
            lv_target = zcl_skylint_ast_util=>get_token_lexeme( is_statement = <ls_statement>
                                                                iv_index     = 4 ).
            CASE <ls_statement>-keyword.
              WHEN 'ADD'.
                lv_op = '+'.
              WHEN 'SUBTRACT'.
                lv_op = '-'.
              WHEN 'MULTIPLY'.
                lv_op = '*'.
              WHEN 'DIVIDE'.
                lv_op = '/'.
            ENDCASE.
            lv_line = |{ lv_target } { lv_op }= { lv_value }.|.
          ENDIF.
          IF lv_line IS NOT INITIAL.
            ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-calc_assign
                                            iv_statement_from = lv_stmt_idx
                                            it_new_code       = VALUE #( ( lv_line ) ) ).
          ENDIF.
          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-calc_assign
                            is_quickfix     = ls_quickfix ).
        WHEN OTHERS.
          lv_tok1 = zcl_skylint_ast_util=>get_token_lexeme( is_statement = <ls_statement>
                                                            iv_index     = 1 ).
          lv_tok3 = zcl_skylint_ast_util=>get_token_lexeme( is_statement = <ls_statement>
                                                            iv_index     = 3 ).
          IF lv_tok1 IS INITIAL OR lv_tok3 IS INITIAL.
            CONTINUE.
          ENDIF.
          IF     lv_tok1 = lv_tok3
             AND zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                         iv_index     = 2
                                                         iv_expected  = `=` )          = abap_true
             AND (    zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                              iv_index     = 4
                                                              iv_expected  = `+` )          = abap_true
                   OR zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                              iv_index     = 4
                                                              iv_expected  = `-` )          = abap_true
                   OR zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                              iv_index     = 4
                                                              iv_expected  = `*` )          = abap_true
                   OR zcl_skylint_ast_util=>matches_token_at( is_statement = <ls_statement>
                                                              iv_index     = 4
                                                              iv_expected  = `/` )          = abap_true ).
            lv_target = lv_tok1.
            lv_op = zcl_skylint_ast_util=>get_token_lexeme( is_statement = <ls_statement>
                                                            iv_index     = 4 ).
            lv_value = zcl_skylint_ast_util=>get_token_lexeme( is_statement = <ls_statement>
                                                               iv_index     = 5 ).
            IF lv_value IS NOT INITIAL
               AND zcl_skylint_ast_util=>token_count( <ls_statement> ) = 5.
              lv_line = |{ lv_target } { lv_op }= { lv_value }.|.
            ENDIF.
            IF lv_line IS NOT INITIAL.
              ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-calc_assign
                                              iv_statement_from = lv_stmt_idx
                                              it_new_code       = VALUE #( ( lv_line ) ) ).
            ENDIF.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-calc_assign
                              is_quickfix     = ls_quickfix ).
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
