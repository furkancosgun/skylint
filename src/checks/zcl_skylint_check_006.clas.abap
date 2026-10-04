CLASS zcl_skylint_check_006 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        omit_exporting TYPE zif_skylint_types=>ty_finding_code VALUE 'OMITEXPORT',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        omit_exporting TYPE zif_skylint_types=>ty_quickfix_code VALUE 'OMIT_EXP',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.
ENDCLASS.


CLASS zcl_skylint_check_006 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Omit explicit EXPORTING in method calls'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code     = c_finding_codes-omit_exporting
                                       severity = zif_skylint_types=>severities-warning
                                       text     = 'Omit explicit EXPORTING keyword in method invocation' ) )
                                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-omit_exporting
                                                                short_text = 'Remove EXPORTING keyword' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx   TYPE i.
    DATA lv_tok_idx    TYPE i.
    DATA lt_expected   TYPE zcl_skylint_ast_util=>ty_token_lexemes.
    DATA ls_quickfix   TYPE zif_skylint_types=>ty_quickfix.
    DATA lt_empty_code TYPE zif_skylint_types=>ty_code_lines.
    FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.

    lt_expected = VALUE #( ( `EXPORTING` ) ).

    LOOP AT is_code_block-statements ASSIGNING <ls_statement>.
      IF    <ls_statement>-keyword = 'METHODS'    OR <ls_statement>-keyword = 'CLASS-METHODS'
         OR <ls_statement>-keyword = 'INTERFACES' OR <ls_statement>-keyword = 'CALL'
         OR <ls_statement>-keyword = 'EVENTS'     OR <ls_statement>-keyword = 'CLASS-EVENTS'.
        CONTINUE.
      ENDIF.

      IF zcl_skylint_ast_util=>statement_is_method_call( <ls_statement> ) = abap_false.
        CONTINUE.
      ENDIF.

      lv_tok_idx = zcl_skylint_ast_util=>find_token_sequence( is_statement = <ls_statement>
                                                              it_expected  = lt_expected ).
      IF lv_tok_idx = 0.
        CONTINUE.
      ENDIF.

      lv_stmt_idx = sy-tabix.
      ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-omit_exporting
                                      iv_statement_from = lv_stmt_idx
                                      iv_token_from     = lv_tok_idx
                                      iv_token_to       = lv_tok_idx
                                      it_new_code       = lt_empty_code ).
      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-omit_exporting
                        is_quickfix     = ls_quickfix ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
