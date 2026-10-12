CLASS zcl_skylint_check_071 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_final TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_FINAL',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        add_final TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'ADDFINAL',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.
ENDCLASS.


CLASS zcl_skylint_check_071 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #(
                            description       = 'Prefer marking non-overridden methods as FINAL'
                            remote_enablement = abap_true
                             finding_codes     = VALUE #(
                                 ( code     = c_finding_codes-prefer_final
                                   severity = if_ci_atc_check=>finding_severities-warning
                                   text     = 'Declare method as FINAL if it is not intended to be redefined' ) )
                             quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-add_final
                                                            short_text = 'Add FINAL' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx TYPE i.
    DATA lv_line     TYPE string.
    DATA ls_quickfix TYPE zcl_skylint_check_base=>ty_quickfix.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind <> if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'CLASS'.
      IF zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                 iv_lexeme    = 'FINAL' ) = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'METHODS'.
      lv_stmt_idx = sy-tabix.
      IF    zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                    iv_lexeme    = 'FINAL' )        = abap_true
         OR zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                    iv_lexeme    = 'ABSTRACT' )     = abap_true
         OR zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                    iv_lexeme    = 'REDEFINITION' ) = abap_true
         OR zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                    iv_lexeme    = 'FOR' )          = abap_true
         OR zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                    iv_lexeme    = 'CONSTRUCTOR' )  = abap_true
         OR zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                    iv_lexeme    = 'DEFAULT' )      = abap_true.
        CONTINUE.
      ENDIF.

      lv_line = zcl_skylint_ast_util=>flatten_statement( is_statement = <ls_statement>
                                   iv_suffix    = ' FINAL' ).
      ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-add_final
                                      iv_statement_from = lv_stmt_idx
                                      it_new_code       = VALUE #( ( lv_line && '.' ) ) ).
      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-prefer_final
                        is_quickfix     = ls_quickfix ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
