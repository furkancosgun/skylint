CLASS zcl_skylint_pref_auth_subrc DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        missing_subrc TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_AUTHS',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_AUTH_SUBRC'.

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
                  pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx  TYPE i.
    DATA ls_next_stmt TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_stmt_idx = sy-tabix.

      IF <ls_statement>-keyword <> 'AUTHORITY-CHECK'.
        CONTINUE.
      ENDIF.

      ls_next_stmt = zcl_skylint_ast_util=>get_next_statement( it_statements    = is_procedure-statements
                                                               iv_current_index = lv_stmt_idx ).

      IF ls_next_stmt-keyword IS INITIAL OR zcl_skylint_ast_util=>statement_checks_sy_subrc( ls_next_stmt ) = abap_false.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-missing_subrc ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
