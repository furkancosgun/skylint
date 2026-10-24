CLASS zcl_skylint_no_dash_in_form DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        names_no_dash TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_DASH',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_DASH'.

ENDCLASS.


CLASS zcl_skylint_no_dash_in_form IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'skylint: No Dashes in Form Names'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-names_no_dash
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Avoid dashes in FORM names'
                                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_name TYPE string.

    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'FORM'.
        CONTINUE.
      ENDIF.

      IF lines( <ls_statement>-tokens ) < 2.
        CONTINUE.
      ENDIF.

      lv_name = zcl_skylint_ast_util=>get_token_lexeme( is_statement = <ls_statement>
                                                        iv_index     = 2 ).
      IF contains( val = lv_name
                   sub = '-' ).
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-names_no_dash ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
