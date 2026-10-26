CLASS zcl_skylint_pref_calc_op DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        calc_assign TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_CALOP',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        calc_assign TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'CALCASGN',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_CALC_OP'.

    METHODS build_replacement_code
      IMPORTING is_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_code) TYPE string.

    METHODS build_obsolete_replacement
      IMPORTING is_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_code) TYPE string.

    METHODS build_self_assign_replacement
      IMPORTING is_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_code) TYPE string.

    METHODS extract_range_code
      IMPORTING is_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_from        TYPE i
                iv_to          TYPE i
      RETURNING VALUE(rv_code) TYPE string.

    METHODS is_calc_operator
      IMPORTING iv_op        TYPE string
      RETURNING VALUE(rv_is) TYPE abap_bool.
ENDCLASS.


CLASS zcl_skylint_pref_calc_op IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Prefer calculation assignment operators (+=, -=, *=, /=)'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-calc_assign
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Use calculation assignment operator (+=, -=) or ADD statement replacement'
                       pseudo_comment = c_pseudo_comment ) )
                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-calc_assign
                                                short_text = 'Use += style assignment' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_replacement TYPE string.
    DATA ls_quickfix    TYPE zcl_skylint_check_base=>ty_quickfix.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF     <ls_statement>-keyword <> 'ADD'
         AND <ls_statement>-keyword <> 'SUBTRACT'
         AND <ls_statement>-keyword <> 'MULTIPLY'
         AND <ls_statement>-keyword <> 'DIVIDE'
         AND <ls_statement>-keyword <> 'COMPUTE'.
        CONTINUE.
      ENDIF.

      lv_replacement = build_replacement_code( <ls_statement> ).
      IF lv_replacement IS INITIAL.
        CONTINUE.
      ENDIF.

      ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-calc_assign
                                      iv_statement_from = sy-tabix
                                      it_new_code       = VALUE #( ( lv_replacement ) ) ).

      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-calc_assign
                        is_quickfix     = ls_quickfix ).
    ENDLOOP.
  ENDMETHOD.

  METHOD build_replacement_code.
    CLEAR rv_code.

    CASE is_statement-keyword.
      WHEN 'ADD' OR 'SUBTRACT' OR 'MULTIPLY' OR 'DIVIDE'.
        rv_code = build_obsolete_replacement( is_statement ).
      WHEN 'COMPUTE'.
        rv_code = build_self_assign_replacement( is_statement ).
    ENDCASE.
  ENDMETHOD.

  METHOD build_obsolete_replacement.
    DATA lv_target TYPE string.
    DATA lv_value  TYPE string.
    DATA lv_op     TYPE string.

    CLEAR rv_code.

    IF zcl_skylint_ast_util=>token_count( is_statement ) <> 4.
      RETURN.
    ENDIF.

    CASE is_statement-keyword.
      WHEN 'ADD'.
        IF zcl_skylint_ast_util=>matches_token_at( is_statement = is_statement
                                                   iv_index     = 3
                                                   iv_expected  = `TO` ) = abap_true.
          lv_op = '+'.
          lv_value = zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                             iv_index     = 2 ).
          lv_target = zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                              iv_index     = 4 ).
        ENDIF.

      WHEN 'SUBTRACT'.
        IF zcl_skylint_ast_util=>matches_token_at( is_statement = is_statement
                                                   iv_index     = 3
                                                   iv_expected  = `FROM` ) = abap_true.
          lv_op = '-'.
          lv_value = zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                             iv_index     = 2 ).
          lv_target = zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                              iv_index     = 4 ).
        ENDIF.

      WHEN 'MULTIPLY'.
        IF zcl_skylint_ast_util=>matches_token_at( is_statement = is_statement
                                                   iv_index     = 3
                                                   iv_expected  = `BY` ) = abap_true.
          lv_op = '*'.
          lv_target = zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                              iv_index     = 2 ).
          lv_value = zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                             iv_index     = 4 ).
        ENDIF.

      WHEN 'DIVIDE'.
        IF zcl_skylint_ast_util=>matches_token_at( is_statement = is_statement
                                                   iv_index     = 3
                                                   iv_expected  = `BY` ) = abap_true.
          lv_op = '/'.
          lv_target = zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                              iv_index     = 2 ).
          lv_value = zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                             iv_index     = 4 ).
        ENDIF.
    ENDCASE.

    IF lv_target IS NOT INITIAL AND lv_value IS NOT INITIAL.
      rv_code = |{ lv_target } { lv_op }= { lv_value }.|.
    ENDIF.
  ENDMETHOD.

  METHOD build_self_assign_replacement.
    DATA lv_count      TYPE i.
    DATA lv_eq_idx     TYPE i.
    DATA lv_target_len TYPE i.
    DATA lv_op_idx     TYPE i.
    DATA lv_target     TYPE string.
    DATA lv_source     TYPE string.
    DATA lv_op         TYPE string.
    DATA lv_value      TYPE string.
    DATA ls_op_tok     TYPE if_ci_atc_source_code_provider=>ty_token.

    CLEAR rv_code.
    lv_count = lines( is_statement-tokens ).
    IF lv_count < 5.
      RETURN.
    ENDIF.

    lv_eq_idx = zcl_skylint_ast_util=>find_token( is_statement   = is_statement
                                                  iv_lexeme      = '='
                                                  iv_start_index = 2 ).
    IF lv_eq_idx <= 1.
      RETURN.
    ENDIF.

    lv_target_len = lv_eq_idx - 1.
    lv_op_idx = lv_eq_idx + lv_target_len + 1.
    IF lv_op_idx >= lv_count.
      RETURN.
    ENDIF.

    lv_target = extract_range_code( is_statement = is_statement
                                    iv_from      = 1
                                    iv_to        = lv_eq_idx - 1 ).
    lv_source = extract_range_code( is_statement = is_statement
                                    iv_from      = lv_eq_idx + 1
                                    iv_to        = lv_eq_idx + lv_target_len ).

    IF lv_target IS INITIAL OR lv_target <> lv_source.
      RETURN.
    ENDIF.

    ls_op_tok = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                 iv_index     = lv_op_idx ).
    IF is_calc_operator( ls_op_tok-lexeme ) = abap_false.
      RETURN.
    ENDIF.
    lv_op = ls_op_tok-lexeme.

    lv_value = extract_range_code( is_statement = is_statement
                                   iv_from      = lv_op_idx + 1
                                   iv_to        = lv_count ).
    IF lv_value IS INITIAL.
      RETURN.
    ENDIF.

    rv_code = |{ lv_target } { lv_op }= { lv_value }.|.
  ENDMETHOD.

  METHOD extract_range_code.
    FIELD-SYMBOLS <ls_tok> TYPE if_ci_atc_source_code_provider=>ty_token.

    LOOP AT is_statement-tokens FROM iv_from TO iv_to ASSIGNING <ls_tok>.
      IF rv_code IS INITIAL.
        rv_code = <ls_tok>-lexeme.
      ELSE.
        rv_code = |{ rv_code } { <ls_tok>-lexeme }|.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_calc_operator.
    CASE iv_op.
      WHEN '+' OR '-' OR '*' OR '/'.
        rv_is = abap_true.
      WHEN OTHERS.
        rv_is = abap_false.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
