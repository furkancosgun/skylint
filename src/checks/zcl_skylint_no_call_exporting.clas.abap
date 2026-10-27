CLASS zcl_skylint_no_call_exporting DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        omit_exporting TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_CALL_EX',
      END OF c_finding_codes.

    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        omit_exporting TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'OMIT_EXP',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_CALL_EXPORTING'.

ENDCLASS.


CLASS zcl_skylint_no_call_exporting IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Omit Redundant EXPORTING in Method Calls'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-omit_exporting
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Omit explicit EXPORTING keyword in method invocation'
                                       pseudo_comment = c_pseudo_comment ) )
                                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-omit_exporting
                                                                short_text = 'Remove EXPORTING keyword' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx   TYPE i.
    DATA lv_tok_idx    TYPE i.
    DATA ls_quickfix   TYPE zcl_skylint_check_base=>ty_quickfix.
    DATA lt_empty_code TYPE zcl_skylint_check_base=>ty_code_lines.
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

      IF zcl_skylint_ast_util=>call_has_other_sections( <ls_statement> ) = abap_true.
        CONTINUE.
      ENDIF.

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
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
