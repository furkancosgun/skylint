CLASS zcl_skylint_check_077 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        unused_var TYPE zif_skylint_types=>ty_finding_code VALUE 'UNUSED_VAR',
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
                                       severity       = zif_skylint_types=>severities-warning
                                       text           = 'Local variable or field symbol is declared but never used'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_var_name TYPE string.
    DATA lv_uses     TYPE i.
    FIELD-SYMBOLS <ls_decl> TYPE zif_skylint_types=>ty_statement.
    FIELD-SYMBOLS <ls_stmt> TYPE zif_skylint_types=>ty_statement.
    FIELD-SYMBOLS <ls_tok>  TYPE zif_skylint_types=>ty_token.

    LOOP AT is_code_block-statements ASSIGNING <ls_decl>
         WHERE keyword = 'DATA' OR keyword = 'FIELD-SYMBOLS'.
      lv_var_name = zcl_skylint_ast_util=>get_token_lexeme( is_statement = <ls_decl>
                                                            iv_index     = 2 ).
      IF lv_var_name IS INITIAL.
        CONTINUE.
      ENDIF.

      lv_uses = 0.
      LOOP AT is_code_block-statements ASSIGNING <ls_stmt>.
        LOOP AT <ls_stmt>-tokens ASSIGNING <ls_tok>.
          IF to_upper( <ls_tok>-lexeme ) = lv_var_name.
            lv_uses = lv_uses + 1.
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
