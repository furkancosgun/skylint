CLASS zcl_skylint_check_025 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        omit_receiving TYPE zif_skylint_types=>ty_finding_code VALUE 'OMITRECEIV',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.
ENDCLASS.


CLASS zcl_skylint_check_025 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Omit RECEIVING in method calls'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-omit_receiving
                                       severity       = zif_skylint_types=>severities-warning
                                       text           = 'Omit RECEIVING keyword; use functional call or omit parameter'
                                       ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_has_receiving  TYPE abap_bool.
    DATA lv_has_exceptions TYPE abap_bool.
    DATA ls_next_tok       TYPE zif_skylint_types=>ty_token.
    FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.

    LOOP AT is_code_block-statements ASSIGNING <ls_statement>.
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
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-omit_receiving ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
