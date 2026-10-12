CLASS zcl_skylint_check_077 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        unused_var TYPE if_ci_atc_check=>ty_finding_code VALUE 'UNUSED_VAR',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NEEDED'.
ENDCLASS.


CLASS zcl_skylint_check_077 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Detect unused local variables and field symbols'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-unused_var
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Local variable or field symbol is declared but never used'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_var_name TYPE string.
    DATA lv_uses     TYPE i.
    FIELD-SYMBOLS <ls_decl> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_tok>  TYPE if_ci_atc_source_code_provider=>ty_token.

    LOOP AT is_procedure-statements ASSIGNING <ls_decl>
         WHERE keyword = 'DATA' OR keyword = 'FIELD-SYMBOLS'.
      lv_var_name = zcl_skylint_ast_util=>get_token_lexeme( is_statement = <ls_decl>
                                                            iv_index     = 2 ).
      IF lv_var_name IS INITIAL.
        CONTINUE.
      ENDIF.

      lv_uses = 0.
      LOOP AT is_procedure-statements ASSIGNING <ls_stmt>.
        LOOP AT <ls_stmt>-tokens ASSIGNING <ls_tok>.
          IF     <ls_tok>-lexeme = lv_var_name
             AND zcl_skylint_ast_util=>has_compiler_reference(
                     is_token = <ls_tok>
                     iv_kind  = if_ci_atc_source_code_provider=>compiler_reference_kinds-method ) = abap_false
             AND zcl_skylint_ast_util=>has_compiler_reference(
                     is_token = <ls_tok>
                     iv_kind  = if_ci_atc_source_code_provider=>compiler_reference_kinds-type )   = abap_false.
            lv_uses += 1.
          ENDIF.
        ENDLOOP.
      ENDLOOP.

      IF lv_uses <= 1.
        report_statement( is_statement    = <ls_decl>
                          iv_finding_code = c_finding_codes-unused_var ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
