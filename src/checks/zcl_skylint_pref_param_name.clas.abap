CLASS zcl_skylint_pref_param_name DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        omit_param    TYPE if_ci_atc_check=>ty_finding_code VALUE 'OMITPARM',
        require_param TYPE if_ci_atc_check=>ty_finding_code VALUE 'REQPARM',
      END OF c_finding_codes.

    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        omit_param    TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'OMITPNAME',
        require_param TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'REQPNAME',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PARAM_NAME'.

    DATA mv_check_param_name   TYPE abap_bool VALUE abap_true.
    DATA mv_require_param_name TYPE abap_bool VALUE abap_false.

    METHODS has_other_sections
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_has) TYPE abap_bool.

    METHODS is_single_named_param_call
      IMPORTING is_statement          TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_tok_idx            TYPE i
                is_ref                TYPE if_ci_atc_source_code_provider=>ty_compiler_reference
      RETURNING VALUE(rv_param_index) TYPE i.

    METHODS check_omit_param_name
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_stmt_idx  TYPE i.

    METHODS check_require_param_name
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_stmt_idx  TYPE i.

    METHODS positional_argument_index
      IMPORTING is_statement        TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_tok_idx          TYPE i
      RETURNING VALUE(rv_arg_index) TYPE i.

ENDCLASS.


CLASS zcl_skylint_pref_param_name IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'skylint: Method Call Parameter Naming Style'
                 remote_enablement = abap_false
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-omit_param
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Omit explicit parameter name in single parameter method call'
                       pseudo_comment = c_pseudo_comment )
                     ( code           = c_finding_codes-require_param
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Add explicit parameter name to positional method call'
                       pseudo_comment = c_pseudo_comment ) )
                 quickfix_codes    = VALUE #(
                     ( code       = c_quickfix_codes-omit_param
                       short_text = 'Drop parameter name' )
                     ( code       = c_quickfix_codes-require_param
                       short_text = 'Add parameter name' ) )
                 attributes        = VALUE #(
                     ( name  = 'CHECK_PARAM_NAME'
                       kind  = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                       value = REF #( mv_check_param_name ) )
                     ( name  = 'REQUIRE_PARAM_NAME'
                       kind  = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                       value = REF #( mv_require_param_name ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_stmt_idx = sy-tabix.

      IF zcl_skylint_ast_util=>statement_is_method_call( <ls_statement> ) = abap_false.
        CONTINUE.
      ENDIF.

      IF zcl_skylint_ast_util=>match_token_sequence( is_statement = <ls_statement>
                                                     it_expected  = VALUE #( ( `CALL` ) ( `METHOD` ) ) ) = abap_true.
        CONTINUE.
      ENDIF.

      IF has_other_sections( <ls_statement> ) = abap_false.
        IF mv_require_param_name = abap_true.
          check_require_param_name( is_statement = <ls_statement>
                                    iv_stmt_idx  = lv_stmt_idx ).
        ELSEIF mv_check_param_name = abap_true.
          check_omit_param_name( is_statement = <ls_statement>
                                 iv_stmt_idx  = lv_stmt_idx ).
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD check_omit_param_name.
    DATA lv_tok_idx   TYPE i.
    DATA lv_param_idx TYPE i.
    DATA lv_line      TYPE string.
    DATA ls_quickfix  TYPE zcl_skylint_check_base=>ty_quickfix.
    DATA lt_deletions TYPE zcl_skylint_ast_util=>ty_token_deletions.
    DATA ls_ref       TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      lv_tok_idx += 1.

      ls_ref = zcl_skylint_ast_util=>get_reference(
                   is_token = <ls_token>
                   iv_kind  = if_ci_atc_source_code_provider=>compiler_reference_kinds-method ).
      IF ls_ref-full_name IS INITIAL.
        CONTINUE.
      ENDIF.

      lv_param_idx = is_single_named_param_call( is_statement = is_statement
                                                 iv_tok_idx   = lv_tok_idx
                                                 is_ref       = ls_ref ).
      IF lv_param_idx > 0.
        CLEAR ls_quickfix.
        lt_deletions = VALUE #( ( lv_param_idx )
                                ( lv_param_idx + 1 ) ).
        lv_line = zcl_skylint_ast_util=>flatten_statement( is_statement = is_statement
                                                           it_deletions = lt_deletions ).
        ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-omit_param
                                        iv_statement_from = iv_stmt_idx
                                        it_new_code       = VALUE #( ( |{ lv_line }.| ) ) ).
        report_statement( is_statement    = is_statement
                          iv_finding_code = c_finding_codes-omit_param
                          is_quickfix     = ls_quickfix ).
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD check_require_param_name.
    DATA lv_tok_idx    TYPE i.
    DATA lv_arg_idx    TYPE i.
    DATA lv_arg_lexeme TYPE string.
    DATA lv_param_name TYPE string.
    DATA lv_line       TYPE string.
    DATA ls_quickfix   TYPE zcl_skylint_check_base=>ty_quickfix.
    DATA ls_ref        TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.
    DATA lt_overrides  TYPE zcl_skylint_ast_util=>ty_token_overrides.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      lv_tok_idx += 1.

      ls_ref = zcl_skylint_ast_util=>get_reference(
                   is_token = <ls_token>
                   iv_kind  = if_ci_atc_source_code_provider=>compiler_reference_kinds-method ).
      IF ls_ref-full_name IS INITIAL.
        CONTINUE.
      ENDIF.

      lv_arg_idx = positional_argument_index( is_statement = is_statement
                                              iv_tok_idx   = lv_tok_idx ).
      IF lv_arg_idx = 0.
        CONTINUE.
      ENDIF.

      zcl_skylint_rtti_util=>get_single_importing_param( EXPORTING iv_full_name  = ls_ref-full_name
                                                         IMPORTING ev_param_name = lv_param_name ).
      IF lv_param_name IS INITIAL.
        CONTINUE.
      ENDIF.

      lv_arg_lexeme = zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                              iv_index     = lv_arg_idx ).
      lt_overrides = VALUE #( ( index  = lv_arg_idx
                                lexeme = |{ lv_param_name } = { lv_arg_lexeme }| ) ).
      lv_line = zcl_skylint_ast_util=>flatten_statement( is_statement = is_statement
                                                         it_overrides = lt_overrides ).
      ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-require_param
                                      iv_statement_from = iv_stmt_idx
                                      it_new_code       = VALUE #( ( |{ lv_line }.| ) ) ).

      report_statement( is_statement    = is_statement
                        iv_finding_code = c_finding_codes-require_param
                        is_quickfix     = ls_quickfix ).
      EXIT.
    ENDLOOP.
  ENDMETHOD.

  METHOD positional_argument_index.
    DATA ls_tok      TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_next_tok TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_open_idx TYPE i.

    rv_arg_index = 0.

    ls_tok = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                              iv_index     = iv_tok_idx ).
    IF ls_tok-lexeme IS INITIAL.
      RETURN.
    ENDIF.

    IF ls_tok-lexeme CP '*('.
      lv_open_idx = iv_tok_idx.
    ELSE.
      ls_tok = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                iv_index     = iv_tok_idx + 1 ).
      IF ls_tok-lexeme <> '('.
        RETURN.
      ENDIF.
      lv_open_idx = iv_tok_idx + 1.
    ENDIF.

    rv_arg_index = lv_open_idx + 1.
    ls_tok = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                              iv_index     = rv_arg_index ).
    IF ls_tok-lexeme IS INITIAL OR ls_tok-lexeme = ')'.
      rv_arg_index = 0.
      RETURN.
    ENDIF.

    ls_next_tok = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                   iv_index     = rv_arg_index + 1 ).
    IF ls_next_tok-lexeme = '='.
      rv_arg_index = 0.
    ENDIF.
  ENDMETHOD.

  METHOD has_other_sections.
    rv_has = abap_false.
    IF    zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                  iv_lexeme    = 'IMPORTING' )  = abap_true
       OR zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                  iv_lexeme    = 'CHANGING' )   = abap_true
       OR zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                  iv_lexeme    = 'RECEIVING' )  = abap_true
       OR zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                  iv_lexeme    = 'RETURNING' )  = abap_true
       OR zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                  iv_lexeme    = 'EXCEPTIONS' ) = abap_true.
      rv_has = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD is_single_named_param_call.
    DATA lv_param_name TYPE string.
    DATA lv_is_single  TYPE abap_bool.
    DATA ls_tok        TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_next_tok   TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_param_idx  TYPE i.

    rv_param_index = 0.

    zcl_skylint_rtti_util=>get_single_importing_param( EXPORTING iv_full_name  = is_ref-full_name
                                                       IMPORTING ev_param_name = lv_param_name
                                                                 ev_is_single  = lv_is_single ).

    IF lv_is_single = abap_false.
      RETURN.
    ENDIF.

    ls_tok = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                              iv_index     = iv_tok_idx ).
    IF ls_tok-lexeme IS INITIAL.
      RETURN.
    ENDIF.

    IF ls_tok-lexeme CP '*('.
      lv_param_idx = iv_tok_idx + 1.
    ELSE.
      ls_tok = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                iv_index     = iv_tok_idx + 1 ).
      IF ls_tok-lexeme <> '('.
        RETURN.
      ENDIF.
      lv_param_idx = iv_tok_idx + 2.
    ENDIF.

    ls_tok = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                              iv_index     = lv_param_idx ).
    IF ls_tok-lexeme = lv_param_name.
      ls_next_tok = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                     iv_index     = lv_param_idx + 1 ).
      IF ls_next_tok-lexeme = '='.
        rv_param_index = lv_param_idx.
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
