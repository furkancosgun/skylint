CLASS zcl_skylint_pref_auth_subrc DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        missing_subrc TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_AUTHS',
      END OF c_finding_codes.

    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        insert_auth_check TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'CHK_AUTHS',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_AUTH_SUBRC'.

    METHODS checks_sy_subrc
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

    METHODS is_subrc_token
      IMPORTING is_token     TYPE if_ci_atc_source_code_provider=>ty_token
      RETURNING VALUE(rv_is) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_pref_auth_subrc IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #(
            description       = 'Check sy-subrc immediately after AUTHORITY-CHECK'
            remote_enablement = abap_true
            finding_codes     = VALUE #(
                ( code           = c_finding_codes-missing_subrc
                  severity       = if_ci_atc_check=>finding_severities-error
                  text           = 'AUTHORITY-CHECK sy-subrc must be checked immediately; failing to check bypasses authorization'
                  pseudo_comment = c_pseudo_comment ) )
            quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-insert_auth_check
                                           short_text = 'Insert sy-subrc check after AUTHORITY-CHECK' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx  TYPE i.
    DATA lv_indent    TYPE string.
    DATA ls_next_stmt TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_quickfix  TYPE ty_quickfix.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_stmt_idx = sy-tabix.

      IF <ls_statement>-keyword <> 'AUTHORITY-CHECK'.
        CONTINUE.
      ENDIF.

      ls_next_stmt = zcl_skylint_ast_util=>get_next_statement( it_statements    = is_procedure-statements
                                                               iv_current_index = lv_stmt_idx ).

      IF ls_next_stmt-keyword IS NOT INITIAL AND checks_sy_subrc( ls_next_stmt ) = abap_true.
        CONTINUE.
      ENDIF.

      CLEAR ls_quickfix.
      IF <ls_statement>-position-column > 1.
        lv_indent = repeat( val = ` `
                            occ = <ls_statement>-position-column - 1 ).
      ELSE.
        lv_indent = ''.
      ENDIF.

      ls_quickfix = quickfix_insert_after( iv_quickfix_code  = c_quickfix_codes-insert_auth_check
                                           iv_statement_from = lv_stmt_idx
                                           it_new_code       = VALUE #( ( |{ lv_indent }IF sy-subrc <> 0.| )
                                                                        ( |{ lv_indent }  RETURN.| )
                                                                        ( |{ lv_indent }ENDIF.| ) ) ).

      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-missing_subrc
                        is_quickfix     = ls_quickfix ).
    ENDLOOP.
  ENDMETHOD.

  METHOD checks_sy_subrc.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_res = abap_false.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      IF is_subrc_token( <ls_token> ) = abap_true.
        rv_res = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_subrc_token.
    rv_is = zcl_skylint_ast_util=>match_system_field( is_token      = is_token
                                                      iv_field_name = 'SUBRC' ).
  ENDMETHOD.
ENDCLASS.
