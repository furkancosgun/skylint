CLASS zcl_skylint_no_ambiguous_stmt DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        ambiguous_statement TYPE if_ci_atc_check=>ty_finding_code VALUE 'AMBIG_STMT',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_AMBIGUOUS_STMT'.

    METHODS is_ambiguous
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_yes) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_no_ambiguous_stmt IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #(
            description       = 'Avoid ambiguous statements between itab and database'
            remote_enablement = abap_true
            finding_codes     = VALUE #(
                ( code           = c_finding_codes-ambiguous_statement
                  severity       = if_ci_atc_check=>finding_severities-warning
                  text           = 'Ambiguous statement; use explicit syntax (TABLE keyword or @ for SQL variables)'
                  pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF is_ambiguous( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-ambiguous_statement ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_ambiguous.
    DATA lv_tokens_count TYPE i.
    DATA lv_from_idx     TYPE i.
    DATA ls_second_tok   TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_from_target  TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_yes = abap_false.
    lv_tokens_count = lines( is_statement-tokens ).

    CASE is_statement-keyword.
      WHEN 'DELETE'.
        IF lv_tokens_count = 2.
          rv_yes = abap_true.
          RETURN.
        ENDIF.

        IF    zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                      iv_lexeme    = 'TABLE' )    = abap_true
           OR zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                      iv_lexeme    = 'INDEX' )    = abap_true
           OR zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                      iv_lexeme    = 'ADJACENT' ) = abap_true.
          RETURN.
        ENDIF.

        ls_second_tok = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                         iv_index     = 2 ).
        IF ls_second_tok-lexeme = 'FROM'.
          RETURN.
        ENDIF.

        lv_from_idx = zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                        iv_lexeme    = 'FROM' ).
        IF lv_from_idx > 2 AND lv_from_idx < lv_tokens_count.
          ls_from_target = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                            iv_index     = lv_from_idx + 1 ).
          IF ls_from_target-lexeme(1) <> '@'.
            rv_yes = abap_true.
          ENDIF.
        ENDIF.

      WHEN 'MODIFY'.
        IF lv_tokens_count = 2.
          rv_yes = abap_true.
          RETURN.
        ENDIF.

        IF    zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                      iv_lexeme    = 'TABLE' )    = abap_true
           OR zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                      iv_lexeme    = 'INDEX' )    = abap_true.
          RETURN.
        ENDIF.

        lv_from_idx = zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                        iv_lexeme    = 'FROM' ).
        IF lv_from_idx > 2 AND lv_from_idx < lv_tokens_count.
          ls_from_target = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                            iv_index     = lv_from_idx + 1 ).
          IF ls_from_target-lexeme(1) <> '@'.
            rv_yes = abap_true.
          ENDIF.
        ENDIF.

      WHEN 'INSERT' OR 'UPDATE'.
        IF lv_tokens_count = 2.
          rv_yes = abap_true.
        ENDIF.

      WHEN OTHERS.
        RETURN.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
