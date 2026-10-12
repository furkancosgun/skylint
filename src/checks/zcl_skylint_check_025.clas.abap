CLASS zcl_skylint_check_025 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        omit_receiving TYPE if_ci_atc_check=>ty_finding_code VALUE 'OMITRECEIV',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        omit_receiving TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'OMITRECV',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.
ENDCLASS.


CLASS zcl_skylint_check_025 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #(
                            description       = 'Omit RECEIVING in method calls'
                            remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code     = c_finding_codes-omit_receiving
                                       severity = if_ci_atc_check=>finding_severities-warning
                                       text     = 'Omit RECEIVING keyword; use functional call or omit parameter' ) )
                                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-omit_receiving
                                                                short_text = 'Hoist RECEIVING to LHS' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_has_receiving  TYPE abap_bool.
    DATA lv_has_exceptions TYPE abap_bool.
    DATA ls_next_tok       TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_stmt_idx       TYPE i.
    DATA lv_line           TYPE string.
    DATA ls_quickfix       TYPE zcl_skylint_check_base=>ty_quickfix.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_stmt_idx = sy-tabix.
      IF    <ls_statement>-keyword = 'METHODS' OR <ls_statement>-keyword = 'CLASS-METHODS'
         OR <ls_statement>-keyword = 'INTERFACES'.
        CONTINUE.
      ENDIF.

      IF zcl_skylint_ast_util=>statement_is_method_call( <ls_statement> ) = abap_false.
        CONTINUE.
      ENDIF.

      lv_has_receiving  = abap_false.
      lv_has_exceptions = abap_false.

      IF zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                 iv_lexeme    = 'RECEIVING' ) = abap_true.
        ls_next_tok = zcl_skylint_ast_util=>get_token_after( is_statement = <ls_statement>
                                                             iv_lexeme    = 'RECEIVING' ).
        IF ls_next_tok-lexeme IS INITIAL OR to_upper( ls_next_tok-lexeme ) <> '='.
          lv_has_receiving = abap_true.
        ENDIF.
      ENDIF.

      IF zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                 iv_lexeme    = 'EXCEPTIONS' ) = abap_true.
        ls_next_tok = zcl_skylint_ast_util=>get_token_after( is_statement = <ls_statement>
                                                             iv_lexeme    = 'EXCEPTIONS' ).
        IF ls_next_tok-lexeme IS INITIAL OR to_upper( ls_next_tok-lexeme ) <> '='.
          lv_has_exceptions = abap_true.
        ENDIF.
      ENDIF.

      IF lv_has_receiving = abap_true AND lv_has_exceptions = abap_false.
        CLEAR ls_quickfix.
        lv_line = build_functional_call( <ls_statement> ).
        IF lv_line IS NOT INITIAL.
          ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-omit_receiving
                                          iv_statement_from = lv_stmt_idx
                                          it_new_code       = VALUE #( ( lv_line ) ) ).
        ENDIF.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-omit_receiving
                          is_quickfix     = ls_quickfix ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
