CLASS zcl_skylint_no_exporting DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        omit_exporting TYPE if_ci_atc_check=>ty_finding_code VALUE 'OMITEXPORT',
        omit_receiving TYPE if_ci_atc_check=>ty_finding_code VALUE 'OMITRECEIV',
        omit_param     TYPE if_ci_atc_check=>ty_finding_code VALUE 'OMITPARM',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        omit_exporting TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'OMIT_EXP',
        omit_receiving TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'OMITRECV',
        omit_param     TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'OMITPNAME',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS:
      BEGIN OF c_pseudo_comments,
        exporting  TYPE string VALUE 'EXPORTING',
        receiving  TYPE string VALUE 'RECEIVING',
        param_name TYPE string VALUE 'PARAM_NAME',
      END OF c_pseudo_comments.

    METHODS has_other_sections
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_has) TYPE abap_bool.

    METHODS has_receiving
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_has) TYPE abap_bool.

    METHODS has_exceptions
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_has) TYPE abap_bool.

    METHODS build_receiving_quickfix
      IMPORTING is_statement       TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_stmt_idx        TYPE i
      RETURNING VALUE(rs_quickfix) TYPE zcl_skylint_check_base=>ty_quickfix.

    METHODS is_single_named_param_call
      IMPORTING is_statement          TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_tok_idx            TYPE i
                is_ref                TYPE if_ci_atc_source_code_provider=>ty_compiler_reference
      RETURNING VALUE(rv_param_index) TYPE i.

ENDCLASS.


CLASS zcl_skylint_no_exporting IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Omit redundant EXPORTING, RECEIVING, and single parameter names in method calls'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-omit_exporting
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Omit explicit EXPORTING keyword in method invocation'
                       pseudo_comment = c_pseudo_comments-exporting )
                     ( code           = c_finding_codes-omit_receiving
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Omit RECEIVING keyword; use functional call or omit parameter'
                       pseudo_comment = c_pseudo_comments-receiving )
                     ( code           = c_finding_codes-omit_param
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Omit explicit parameter name in single parameter method call'
                       pseudo_comment = c_pseudo_comments-param_name ) )
                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-omit_exporting
                                                short_text = 'Remove EXPORTING keyword' )
                                              ( code       = c_quickfix_codes-omit_receiving
                                                short_text = 'Hoist RECEIVING to LHS' )
                                              ( code       = c_quickfix_codes-omit_param
                                                short_text = 'Drop parameter name' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx   TYPE i.
    DATA lv_tok_idx    TYPE i.
    DATA lv_param_idx  TYPE i.
    DATA lv_line       TYPE string.
    DATA ls_quickfix   TYPE zcl_skylint_check_base=>ty_quickfix.
    DATA lt_empty_code TYPE zcl_skylint_check_base=>ty_code_lines.
    DATA lt_deletions  TYPE zcl_skylint_ast_util=>ty_token_deletions.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_token>     TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_ref>       TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_stmt_idx = sy-tabix.

      IF zcl_skylint_ast_util=>statement_is_method_call( <ls_statement> ) = abap_false.
        CONTINUE.
      ENDIF.

      IF zcl_skylint_ast_util=>match_token_sequence( is_statement = <ls_statement>
                                                     it_expected  = VALUE #( ( `CALL` ) ( `METHOD` ) ) ) = abap_true.
        CONTINUE.
      ENDIF.

      " 1. Check RECEIVING
      IF has_exceptions( <ls_statement> ) = abap_false AND has_receiving( <ls_statement> ) = abap_true.
        ls_quickfix = build_receiving_quickfix( is_statement = <ls_statement>
                                                iv_stmt_idx  = lv_stmt_idx ).
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-omit_receiving
                          is_quickfix     = ls_quickfix ).
        CONTINUE.
      ENDIF.

      " 2. Check EXPORTING
      IF has_other_sections( <ls_statement> ) = abap_false.
        lv_tok_idx = zcl_skylint_ast_util=>find_token( is_statement = <ls_statement>
                                                       iv_lexeme    = 'EXPORTING' ).
        IF lv_tok_idx > 0.
          ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-omit_exporting
                                          iv_statement_from = lv_stmt_idx
                                          iv_token_from     = lv_tok_idx
                                          iv_token_to       = lv_tok_idx
                                          it_new_code       = lt_empty_code ).

          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-omit_exporting
                            is_quickfix     = ls_quickfix ).
          CONTINUE.
        ENDIF.

        " 3. Check single parameter name (no EXPORTING, no other sections)
        lv_tok_idx = 0.
        LOOP AT <ls_statement>-tokens ASSIGNING <ls_token>.
          lv_tok_idx += 1.

          LOOP AT <ls_token>-references ASSIGNING <ls_ref>
               WHERE kind = if_ci_atc_source_code_provider=>compiler_reference_kinds-method.
            lv_param_idx = is_single_named_param_call( is_statement = <ls_statement>
                                                       iv_tok_idx   = lv_tok_idx
                                                       is_ref       = <ls_ref> ).
            IF lv_param_idx > 0.
              CLEAR ls_quickfix.
              lt_deletions = VALUE #( ( lv_param_idx )
                                      ( lv_param_idx + 1 ) ).
              lv_line = zcl_skylint_ast_util=>flatten_statement( is_statement = <ls_statement>
                                                                 it_deletions = lt_deletions ).
              ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-omit_param
                                              iv_statement_from = lv_stmt_idx
                                              it_new_code       = VALUE #( ( |{ lv_line }.| ) ) ).
              report_statement( is_statement    = <ls_statement>
                                iv_finding_code = c_finding_codes-omit_param
                                is_quickfix     = ls_quickfix ).
              EXIT.
            ENDIF.
          ENDLOOP.
        ENDLOOP.
      ENDIF.
    ENDLOOP.
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

  METHOD has_receiving.
    rv_has = zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                     iv_lexeme    = 'RECEIVING' ).
  ENDMETHOD.

  METHOD has_exceptions.
    rv_has = zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                     iv_lexeme    = 'EXCEPTIONS' ).
  ENDMETHOD.

  METHOD build_receiving_quickfix.
    DATA lv_recv_idx  TYPE i.
    DATA lv_target    TYPE string.
    DATA lv_code      TYPE string.
    DATA lt_deletions TYPE zcl_skylint_ast_util=>ty_token_deletions.

    lv_recv_idx = zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                    iv_lexeme    = 'RECEIVING' ).
    IF lv_recv_idx = 0 OR lv_recv_idx + 3 > lines( is_statement-tokens ).
      RETURN.
    ENDIF.

    lv_target = zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                        iv_index     = lv_recv_idx + 3 ).
    IF lv_target IS INITIAL.
      RETURN.
    ENDIF.

    lt_deletions = VALUE #( ( lv_recv_idx )
                            ( lv_recv_idx + 1 )
                            ( lv_recv_idx + 2 )
                            ( lv_recv_idx + 3 ) ).

    lv_code = zcl_skylint_ast_util=>flatten_statement( is_statement = is_statement
                                                       it_deletions = lt_deletions ).

    rs_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-omit_receiving
                                    iv_statement_from = iv_stmt_idx
                                    it_new_code       = VALUE #( ( |{ lv_target } = { lv_code }.| ) ) ).
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
