CLASS zcl_skylint_no_dash_in_form DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        names_no_dash TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_DASH_FM',
      END OF c_finding_codes.

    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        dash_to_underscore TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'DASH2UND',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_DASH_IN_FORM'.

ENDCLASS.


CLASS zcl_skylint_no_dash_in_form IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'No Dashes in Form Names'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-names_no_dash
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Avoid dashes in FORM names'
                       pseudo_comment = c_pseudo_comment ) )
                 quickfix_codes    = VALUE #(
                     ( code       = c_quickfix_codes-dash_to_underscore
                       short_text = 'Replace dash with underscore' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_idx       TYPE i.
    DATA lv_name      TYPE string.
    DATA lv_clean     TYPE string.
    DATA lv_line      TYPE string.
    DATA ls_quickfix  TYPE zcl_skylint_check_base=>ty_quickfix.
    DATA lt_overrides TYPE zcl_skylint_ast_util=>ty_token_overrides.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'FORM'.
        CONTINUE.
      ENDIF.

      IF lines( <ls_statement>-tokens ) < 2.
        CONTINUE.
      ENDIF.

      lv_idx = sy-tabix.
      lv_name = zcl_skylint_ast_util=>get_token_lexeme( is_statement = <ls_statement>
                                                        iv_index     = 2 ).
      IF contains( val = lv_name
                   sub = '-' ).
        lv_clean = replace( val  = lv_name
                            sub  = '-'
                            with = '_'
                            occ  = 0 ).
        lt_overrides = VALUE #( ( index  = 2
                                  lexeme = lv_clean ) ).
        lv_line = zcl_skylint_ast_util=>flatten_statement( is_statement = <ls_statement>
                                                           it_overrides = lt_overrides
                                                           iv_suffix    = '.' ).
        ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-dash_to_underscore
                                        iv_statement_from = lv_idx
                                        it_new_code       = VALUE #( ( lv_line ) ) ).

        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-names_no_dash
                          is_quickfix     = ls_quickfix ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
