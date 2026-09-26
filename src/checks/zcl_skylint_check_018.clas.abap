CLASS zcl_skylint_check_018 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        unit_test_assert TYPE if_ci_atc_check=>ty_finding_code VALUE 'UTASSERT',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'UT_ASSERT'.

    METHODS is_assert_call
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

    METHODS get_param_value
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_param      TYPE string
      RETURNING VALUE(rv_val) TYPE string.

    METHODS has_invalid_assertion
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_check_018 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Validate unit test assertions (avoid identical act and exp parameters)'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-unit_test_assert
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Invalid unit test assertion; actual and expected parameters are identical'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF has_invalid_assertion( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-unit_test_assert ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD has_invalid_assertion.
    DATA lv_act TYPE string.
    DATA lv_exp TYPE string.

    rv_res = abap_false.
    IF is_assert_call( is_statement ) = abap_false.
      RETURN.
    ENDIF.

    lv_act = get_param_value( is_statement = is_statement
                              iv_param     = 'ACT' ).
    IF lv_act IS INITIAL.
      lv_act = get_param_value( is_statement = is_statement
                                iv_param     = 'ACTUAL' ).
    ENDIF.

    lv_exp = get_param_value( is_statement = is_statement
                              iv_param     = 'EXP' ).
    IF lv_exp IS INITIAL.
      lv_exp = get_param_value( is_statement = is_statement
                                iv_param     = 'EXPECTED' ).
    ENDIF.

    IF     lv_act             IS NOT INITIAL
       AND lv_exp             IS NOT INITIAL
       AND to_upper( lv_act )  = to_upper( lv_exp ).
      rv_res = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD is_assert_call.
    DATA lv_tok TYPE string.
    FIELD-SYMBOLS <ls_tok> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_res = abap_false.
    LOOP AT is_statement-tokens ASSIGNING <ls_tok>.
      lv_tok = to_upper( <ls_tok>-lexeme ).
      IF lv_tok CP '*ASSERT*' OR lv_tok CP '*CL_AUNIT_ASSERT*' OR lv_tok CP '*CL_ABAP_UNIT_ASSERT*'.
        rv_res = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_param_value.
    DATA lv_idx   TYPE i.
    DATA lv_total TYPE i.
    DATA lv_in    TYPE abap_bool.
    DATA lv_depth TYPE i.
    DATA lv_curr  TYPE string.
    FIELD-SYMBOLS <ls_t> TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_n> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_val = ''.
    lv_in = abap_false.
    lv_depth = 0.
    lv_total = lines( is_statement-tokens ).
    lv_idx = 1.

    WHILE lv_idx <= lv_total.
      ASSIGN is_statement-tokens[ lv_idx ] TO <ls_t>.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.

      lv_curr = to_upper( <ls_t>-lexeme ).

      IF lv_in = abap_false.
        IF lv_curr = iv_param AND lv_idx < lv_total.
          ASSIGN is_statement-tokens[ lv_idx + 1 ] TO <ls_n>.
          IF sy-subrc = 0 AND <ls_n>-lexeme = '='.
            lv_in = abap_true.
            lv_depth = 0.
            lv_idx += 2.
            CONTINUE.
          ENDIF.
        ENDIF.
      ELSE.
        IF lv_curr CP '*( *' OR lv_curr = '('.
          lv_depth += 1.
        ELSEIF lv_curr CP '* )*' OR lv_curr = ')'.
          IF lv_depth > 0.
            lv_depth -= 1.
          ELSE.
            RETURN.
          ENDIF.
        ENDIF.

        IF lv_depth = 0 AND lv_idx < lv_total.
          ASSIGN is_statement-tokens[ lv_idx + 1 ] TO <ls_n>.
          IF sy-subrc = 0 AND <ls_n>-lexeme = '='.
            " Next parameter encountered
            RETURN.
          ENDIF.
        ENDIF.

        IF rv_val IS INITIAL.
          rv_val = <ls_t>-lexeme.
        ELSE.
          rv_val = |{ rv_val } { <ls_t>-lexeme }|.
        ENDIF.
      ENDIF.

      lv_idx += 1.
    ENDWHILE.
  ENDMETHOD.
ENDCLASS.
