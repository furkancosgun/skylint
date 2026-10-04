CLASS zcl_skylint_check_071 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_final TYPE zif_skylint_types=>ty_finding_code VALUE 'PREF_FINAL',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.
ENDCLASS.


CLASS zcl_skylint_check_071 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Prefer marking non-overridden methods as FINAL'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-prefer_final
                                       severity       = zif_skylint_types=>severities-warning
                                       text           = 'Declare method as FINAL if it is not intended to be redefined'
                                       ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.

    IF is_code_block-block_kind <> zif_skylint_types=>block_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_code_block-statements ASSIGNING <ls_statement>
         WHERE keyword = 'CLASS'.
      IF zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                 iv_lexeme    = 'FINAL' ) = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.

    LOOP AT is_code_block-statements ASSIGNING <ls_statement>
         WHERE keyword = 'METHODS'.
      IF    zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                    iv_lexeme    = 'FINAL' ) = abap_true
         OR zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                    iv_lexeme    = 'ABSTRACT' ) = abap_true
         OR zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                    iv_lexeme    = 'REDEFINITION' ) = abap_true
         OR zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                    iv_lexeme    = 'FOR' ) = abap_true
         OR zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                    iv_lexeme    = 'CONSTRUCTOR' ) = abap_true
         OR zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                    iv_lexeme    = 'DEFAULT' ) = abap_true.
        CONTINUE.
      ENDIF.

      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-prefer_final ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
