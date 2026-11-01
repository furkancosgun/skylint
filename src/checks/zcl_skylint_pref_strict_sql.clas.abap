CLASS zcl_skylint_pref_strict_sql DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        strict_sql TYPE if_ci_atc_check=>ty_finding_code VALUE 'STRICT_SQL',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_STRICT_SQL'.

    METHODS has_unescaped_host_var
      IMPORTING is_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_unes) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_pref_strict_sql IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Prefer strict SQL; escape host variables and targets with @'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-strict_sql
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Use strict SQL syntax; escape host variables and targets with @'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF zcl_skylint_ast_util=>statement_is_db_access( <ls_statement> ) = abap_false.
        CONTINUE.
      ENDIF.

      IF has_unescaped_host_var( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-strict_sql ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD has_unescaped_host_var.
    DATA lv_idx   TYPE i.
    DATA lv_total TYPE i.
    DATA ls_tok   TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_unes = abap_false.
    lv_total = lines( is_statement-tokens ).

    lv_idx = zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                               iv_lexeme    = 'INTO' ).
    IF lv_idx <= 0.
      RETURN.
    ENDIF.

    IF lv_idx + 1 > lv_total.
      RETURN.
    ENDIF.

    ls_tok = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                              iv_index     = lv_idx + 1 ).
    CASE ls_tok-lexeme.
      WHEN 'TABLE'.
        IF lv_idx + 2 <= lv_total.
          ls_tok = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                    iv_index     = lv_idx + 2 ).
        ENDIF.

      WHEN 'CORRESPONDING'.
        lv_idx = zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                   iv_lexeme    = 'OF' ).
        IF lv_idx > 0 AND lv_idx + 1 <= lv_total.
          ls_tok = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                    iv_index     = lv_idx + 1 ).
          IF ls_tok-lexeme = 'TABLE' AND lv_idx + 2 <= lv_total.
            ls_tok = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                      iv_index     = lv_idx + 2 ).
          ENDIF.
        ENDIF.
    ENDCASE.

    IF ls_tok-lexeme IS NOT INITIAL AND ls_tok-lexeme(1) <> '@'.
      rv_unes = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
