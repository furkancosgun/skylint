CLASS zcl_skylint_pref_enum DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_enum TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_ENUM',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_ENUM'.

ENDCLASS.


CLASS zcl_skylint_pref_enum IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Prefer ENUM over CONSTANTS for set of related values'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-prefer_enum
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Prefer ENUM over CONSTANTS for set of related values'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'CONSTANTS'.
        CONTINUE.
      ENDIF.

      IF     zcl_skylint_ast_util=>has_token_lexeme(
                 is_statement = <ls_statement>
                 iv_lexeme    = 'BEGIN' ) = abap_true
         AND zcl_skylint_ast_util=>has_token_lexeme(
                 is_statement = <ls_statement>
                 iv_lexeme    = 'OF' )    = abap_true.

        report_statement(
            is_statement    = <ls_statement>
            iv_finding_code = c_finding_codes-prefer_enum ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
