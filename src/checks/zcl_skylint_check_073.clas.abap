CLASS zcl_skylint_check_073 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        calc_assign TYPE if_ci_atc_check=>ty_finding_code VALUE 'CALC_ASSGN',
      END OF c_finding_codes.

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
                       text     = 'Use calculation assignment operator (+=, -=) or ADD statement replacement' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_tok1 TYPE string.
    DATA lv_tok3 TYPE string.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'ADD' OR 'SUBTRACT' OR 'MULTIPLY' OR 'DIVIDE'.
          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-calc_assign ).
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
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-calc_assign ).
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
