CLASS zcl_skylint_check_090 DEFINITION
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

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREFER_CALC_ASSIGN'.
ENDCLASS.


CLASS zcl_skylint_check_090 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Prefer calculation assignment operators (+=, -=, *=, /=) over var = var + 1'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-calc_assign
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Use calculation assignment operator (+=, -=) or ADD statement replacement'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_tok1 TYPE string.
    DATA lv_tok2 TYPE string.
    DATA lv_tok3 TYPE string.
    DATA lv_tok4 TYPE string.
    DATA ls_tok1 TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_tok2 TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_tok3 TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_tok4 TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_found1 TYPE abap_bool.
    DATA lv_found2 TYPE abap_bool.
    DATA lv_found3 TYPE abap_bool.
    DATA lv_found4 TYPE abap_bool.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'ADD' OR 'SUBTRACT' OR 'MULTIPLY' OR 'DIVIDE'.
          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-calc_assign ).
        WHEN OTHERS.
          get_token_safe( EXPORTING is_statement = <ls_statement>
                                    iv_index     = 1
                          IMPORTING es_token     = ls_tok1
                                    ev_found     = lv_found1 ).
          get_token_safe( EXPORTING is_statement = <ls_statement>
                                    iv_index     = 2
                          IMPORTING es_token     = ls_tok2
                                    ev_found     = lv_found2 ).
          get_token_safe( EXPORTING is_statement = <ls_statement>
                                    iv_index     = 3
                          IMPORTING es_token     = ls_tok3
                                    ev_found     = lv_found3 ).
          get_token_safe( EXPORTING is_statement = <ls_statement>
                                    iv_index     = 4
                          IMPORTING es_token     = ls_tok4
                                    ev_found     = lv_found4 ).
          IF lv_found1 = abap_false OR lv_found2 = abap_false.
            CONTINUE.
          ENDIF.
          IF lv_found3 = abap_false OR lv_found4 = abap_false.
            CONTINUE.
          ENDIF.
          lv_tok1 = to_upper( ls_tok1-lexeme ).
          lv_tok2 = to_upper( ls_tok2-lexeme ).
          lv_tok3 = to_upper( ls_tok3-lexeme ).
          lv_tok4 = to_upper( ls_tok4-lexeme ).
          IF lv_tok2 = '=' AND lv_tok1 = lv_tok3.
            CASE lv_tok4.
              WHEN '+' OR '-' OR '*' OR '/'.
                report_statement( is_statement    = <ls_statement>
                                  iv_finding_code = c_finding_codes-calc_assign ).
              WHEN OTHERS.
                CONTINUE.
            ENDCASE.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
