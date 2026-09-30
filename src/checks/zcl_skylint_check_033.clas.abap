CLASS zcl_skylint_check_033 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        lost_previous TYPE if_ci_atc_check=>ty_finding_code VALUE 'LOSTPREV',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'LOST_PREVIOUS'.

    METHODS extract_catch_var
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_var) TYPE string.

    METHODS has_previous_parameter
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_caught_var TYPE string
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_033 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Lost PREVIOUS exception parameter in CATCH block'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-lost_previous
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Pass caught exception to PREVIOUS parameter when raising new exception'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_caught_var TYPE string.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'CATCH'.
          lv_caught_var = extract_catch_var( <ls_statement> ).
        WHEN 'CLEANUP' OR 'ENDTRY'.
          CLEAR lv_caught_var.
        WHEN 'RAISE'.
          IF     lv_caught_var IS NOT INITIAL
             AND has_previous_parameter( is_statement  = <ls_statement>
                                         iv_caught_var = lv_caught_var )  = abap_false.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-lost_previous ).
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD extract_catch_var.
    DATA lv_idx TYPE i.
    DATA lv_cnt TYPE i.
    DATA ls_tok TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_next TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_found TYPE abap_bool.

    rv_var = ''.
    lv_cnt = lines( is_statement-tokens ).

    LOOP AT is_statement-tokens INTO ls_tok.
      lv_idx = sy-tabix.
      get_token_safe( EXPORTING is_statement = is_statement
                                iv_index     = lv_idx + 1
                      IMPORTING es_token     = ls_next
                                ev_found     = lv_found ).
      IF ls_tok-lexeme = 'INTO' AND lv_idx < lv_cnt AND lv_found = abap_true.
        rv_var = ls_next-lexeme.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD has_previous_parameter.
    DATA ls_tok TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_tok2 TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_tok3 TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_found2 TYPE abap_bool.
    DATA lv_found3 TYPE abap_bool.

    rv_res = abap_false.

    " If statement is directly re-raising the caught exception variable (e.g. RAISE EXCEPTION lx_exc)
    get_token_safe( EXPORTING is_statement = is_statement
                              iv_index     = 2
                    IMPORTING es_token     = ls_tok2
                              ev_found     = lv_found2 ).
    get_token_safe( EXPORTING is_statement = is_statement
                              iv_index     = 3
                    IMPORTING es_token     = ls_tok3
                              ev_found     = lv_found3 ).
    IF lines( is_statement-tokens ) = 3 AND lv_found2 = abap_true AND lv_found3 = abap_true
       AND ls_tok2-lexeme = 'EXCEPTION' AND ls_tok3-lexeme = iv_caught_var.
      rv_res = abap_true.
      RETURN.
    ENDIF.

    LOOP AT is_statement-tokens INTO ls_tok.
      IF ls_tok-lexeme = 'PREVIOUS' OR ls_tok-lexeme CP '*PREVIOUS=*'.
        rv_res = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
