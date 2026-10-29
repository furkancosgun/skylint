CLASS zcl_skylint_no_exc_chain DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        missing_previous TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_EXCCHN',
      END OF c_finding_codes.

    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        add_previous TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'ADD_PREV',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_EXC_CHAIN'.

    DATA mv_require_previous TYPE abap_bool VALUE abap_true.

    METHODS is_raise_exception
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_is) TYPE abap_bool.

    METHODS has_previous_equal
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_has) TYPE abap_bool.

    METHODS build_chain_quickfix
      IMPORTING is_statement       TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_stmt_idx        TYPE i
                iv_catch_var       TYPE string
      RETURNING VALUE(rs_quickfix) TYPE ty_quickfix.

ENDCLASS.


CLASS zcl_skylint_no_exc_chain IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Preserve the original exception with PREVIOUS'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-missing_previous
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Converted exception does not follow the PREVIOUS chaining policy'
                       pseudo_comment = c_pseudo_comment ) )
                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-add_previous
                                                short_text = 'Add PREVIOUS to exception chaining' ) )
                 attributes        = VALUE #( ( name  = 'REQUIRE_PREVIOUS'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                                value = REF #( mv_require_previous ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_in_catch     TYPE abap_bool.
    DATA lv_has_previous TYPE abap_bool.
    DATA lv_catch_var    TYPE string.
    DATA lv_into_idx     TYPE i.
    DATA lv_stmt_idx     TYPE i.
    DATA ls_into_tok     TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_quickfix     TYPE ty_quickfix.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_stmt_idx = sy-tabix.
      CASE <ls_statement>-keyword.
        WHEN 'CATCH'.
          CLEAR lv_catch_var.
          lv_into_idx = zcl_skylint_ast_util=>find_token( is_statement = <ls_statement>
                                                          iv_lexeme    = 'INTO' ).
          IF lv_into_idx > 0.
            ls_into_tok = zcl_skylint_ast_util=>get_token( is_statement = <ls_statement>
                                                           iv_index     = lv_into_idx + 1 ).
            lv_catch_var = zcl_skylint_ast_util=>extract_name_from_paren( ls_into_tok-lexeme ).
            lv_in_catch = abap_true.
          ELSE.
            lv_in_catch = abap_false.
          ENDIF.

        WHEN 'ENDTRY'.
          lv_in_catch = abap_false.
          CLEAR lv_catch_var.

        WHEN 'RAISE'.
          IF lv_in_catch = abap_true AND is_raise_exception( <ls_statement> ) = abap_true.
            lv_has_previous = has_previous_equal( <ls_statement> ).

            IF    ( mv_require_previous = abap_true  AND lv_has_previous = abap_false )
               OR ( mv_require_previous = abap_false AND lv_has_previous = abap_true ).
              CLEAR ls_quickfix.
              IF     mv_require_previous  = abap_true
                 AND lv_has_previous      = abap_false
                 AND lv_catch_var        IS NOT INITIAL.
                ls_quickfix = build_chain_quickfix( is_statement = <ls_statement>
                                                    iv_stmt_idx  = lv_stmt_idx
                                                    iv_catch_var = lv_catch_var ).
              ENDIF.

              report_statement( is_statement    = <ls_statement>
                                iv_finding_code = c_finding_codes-missing_previous
                                is_quickfix     = ls_quickfix ).
            ENDIF.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_raise_exception.
    DATA ls_token TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_is = abap_false.
    IF is_statement-keyword <> 'RAISE'.
      RETURN.
    ENDIF.

    ls_token = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                iv_index     = 2 ).
    IF ls_token-lexeme <> 'EXCEPTION'.
      RETURN.
    ENDIF.

    ls_token = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                iv_index     = 3 ).
    IF ls_token-lexeme = 'TYPE' OR ls_token-lexeme = 'NEW'.
      rv_is = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD has_previous_equal.
    DATA lv_idx  TYPE i.
    DATA ls_tok  TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_next TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_has = abap_false.
    LOOP AT is_statement-tokens INTO ls_tok.
      lv_idx = sy-tabix.
      IF ls_tok-lexeme = 'PREVIOUS'.
        ls_next = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                   iv_index     = lv_idx + 1 ).
        IF ls_next-lexeme = '='.
          rv_has = abap_true.
          RETURN.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD build_chain_quickfix.
    DATA ls_token     TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_last_tok  TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_last_idx  TYPE i.
    DATA lt_overrides TYPE zcl_skylint_ast_util=>ty_token_overrides.
    DATA lv_line      TYPE string.

    CLEAR rs_quickfix.
    IF iv_catch_var IS INITIAL.
      RETURN.
    ENDIF.

    lv_last_idx = zcl_skylint_ast_util=>token_count( is_statement ).
    IF lv_last_idx < 3.
      RETURN.
    ENDIF.

    ls_token = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                iv_index     = 3 ).
    ls_last_tok = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                   iv_index     = lv_last_idx ).

    CASE ls_token-lexeme.
      WHEN 'NEW'.
        lt_overrides = VALUE #( ( index  = lv_last_idx
                                  lexeme = |previous = { iv_catch_var } )| ) ).
      WHEN 'TYPE'.
        IF zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                   iv_lexeme    = 'EXPORTING' ) = abap_true.
          lt_overrides = VALUE #( ( index  = lv_last_idx
                                    lexeme = |{ ls_last_tok-lexeme } previous = { iv_catch_var }| ) ).
        ELSE.
          lt_overrides = VALUE #( ( index  = lv_last_idx
                                    lexeme = |{ ls_last_tok-lexeme } EXPORTING previous = { iv_catch_var }| ) ).
        ENDIF.
    ENDCASE.

    IF lt_overrides IS INITIAL.
      RETURN.
    ENDIF.

    lv_line = zcl_skylint_ast_util=>flatten_statement( is_statement = is_statement
                                                       it_overrides = lt_overrides
                                                       iv_suffix    = '.' ).

    rs_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-add_previous
                                    iv_statement_from = iv_stmt_idx
                                    it_new_code       = VALUE #( ( lv_line ) ) ).
  ENDMETHOD.
ENDCLASS.
