CLASS zcl_skylint_no_raise_shortdump DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        raise_shortdump TYPE if_ci_atc_check=>ty_finding_code VALUE 'SHORTDUMP',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'SHORTDUMP'.

ENDCLASS.


CLASS zcl_skylint_no_raise_shortdump IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'skylint: Avoid RAISE SHORTDUMP'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-raise_shortdump
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Avoid RAISE SHORTDUMP; prefer graceful class-based exceptions'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF     <ls_statement>-keyword = 'RAISE'
         AND zcl_skylint_ast_util=>has_token_lexeme( is_statement = <ls_statement>
                                                     iv_lexeme    = 'SHORTDUMP' )  = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-raise_shortdump ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
