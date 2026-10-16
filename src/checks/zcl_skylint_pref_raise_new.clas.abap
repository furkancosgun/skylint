CLASS zcl_skylint_pref_raise_new DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        raise_exception_new TYPE if_ci_atc_check=>ty_finding_code VALUE 'RAISEEXCNE',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        raise_new TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'RAISENEW',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'RAISE_NEW'.
    METHODS is_raise_exception_type
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

    METHODS build_new_raise
      IMPORTING is_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_line) TYPE string.

ENDCLASS.


CLASS zcl_skylint_pref_raise_new IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Prefer RAISE EXCEPTION NEW over RAISE EXCEPTION TYPE'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code     = c_finding_codes-raise_exception_new
                                       severity = if_ci_atc_check=>finding_severities-warning
                                       text     = 'Prefer RAISE EXCEPTION NEW cx_name( ) over RAISE EXCEPTION TYPE'
                                       pseudo_comment = c_pseudo_comment ) )
                                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-raise_new
                                                                short_text = 'Use RAISE EXCEPTION NEW' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx TYPE i.
    DATA lv_line     TYPE string.
    DATA ls_quickfix TYPE zcl_skylint_check_base=>ty_quickfix.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'RAISE'.
      lv_stmt_idx = sy-tabix.
      IF is_raise_exception_type( <ls_statement> ) = abap_false.
        CONTINUE.
      ENDIF.

      CLEAR ls_quickfix.
      lv_line = build_new_raise( <ls_statement> ).
      IF lv_line IS NOT INITIAL.
        ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-raise_new
                                        iv_statement_from = lv_stmt_idx
                                        it_new_code       = VALUE #( ( lv_line ) ) ).
      ENDIF.
      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-raise_exception_new
                        is_quickfix     = ls_quickfix ).
    ENDLOOP.
  ENDMETHOD.

  METHOD is_raise_exception_type.
    rv_res = abap_false.
    IF zcl_skylint_ast_util=>find_token_sequence( is_statement = is_statement
                                                  it_expected  = VALUE #( ( `RAISE` ) ( `EXCEPTION` ) ( `TYPE` ) ) ) > 0.
      rv_res = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD build_new_raise.
    DATA lv_count TYPE i.
    DATA lv_idx   TYPE i.
    DATA lv_class TYPE string.
    DATA lv_token TYPE string.
    DATA lv_name  TYPE string.
    DATA lv_value TYPE string.
    DATA lv_args  TYPE string.
    DATA lv_first TYPE abap_bool.

    CLEAR rv_line.
    lv_count = zcl_skylint_ast_util=>token_count( is_statement ).
    IF lv_count < 4.
      RETURN.
    ENDIF.

    IF zcl_skylint_ast_util=>match_token_sequence( is_statement = is_statement
                                                   it_expected  = VALUE #( ( `RAISE` )
                                                                           ( `EXCEPTION` )
                                                                           ( `TYPE` ) ) ) = abap_false.
      RETURN.
    ENDIF.

    lv_class = zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                       iv_index     = 4 ).
    IF lv_class IS INITIAL OR lv_class CS '('.
      RETURN.
    ENDIF.

    lv_idx = 5.
    lv_first = abap_true.
    WHILE lv_idx <= lv_count.
      lv_token = zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                         iv_index     = lv_idx ).
      IF lv_token <> 'EXPORTING'.
        RETURN.
      ENDIF.
      lv_idx += 1.
      WHILE lv_idx + 2 <= lv_count.
        lv_name = zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                          iv_index     = lv_idx ).
        IF    lv_name IS INITIAL
           OR zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                      iv_index     = lv_idx + 1 ) <> '='.
          RETURN.
        ENDIF.
        lv_value = zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                           iv_index     = lv_idx + 2 ).
        IF lv_value IS INITIAL.
          RETURN.
        ENDIF.
        IF lv_first = abap_true.
          lv_first = abap_false.
        ELSE.
          lv_args = |{ lv_args } |.
        ENDIF.
        lv_args = |{ lv_args }{ lv_name } = { lv_value }|.
        lv_idx += 3.
      ENDWHILE.
      IF lv_idx <= lv_count.
        RETURN.
      ENDIF.
    ENDWHILE.

    IF lv_args IS INITIAL.
      lv_args = `( )`.
    ELSE.
      lv_args = |( { lv_args } )|.
    ENDIF.

    rv_line = |RAISE EXCEPTION NEW { lv_class }{ lv_args }.|.
  ENDMETHOD.
ENDCLASS.
