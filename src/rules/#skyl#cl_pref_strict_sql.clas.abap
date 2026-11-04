CLASS /skyl/cl_pref_strict_sql DEFINITION
  PUBLIC
  INHERITING FROM /skyl/cl_rule_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        strict_sql TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_SQL',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS execute REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_STRICT_SQL'.

    METHODS has_unescaped_host_var
      IMPORTING is_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_unes) TYPE abap_bool.

ENDCLASS.


CLASS /skyl/cl_pref_strict_sql IMPLEMENTATION.
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

  METHOD execute.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF /skyl/cl_ast_util=>statement_is_db_access( <ls_statement> ) = abap_false.
        CONTINUE.
      ENDIF.

      IF has_unescaped_host_var( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-strict_sql ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD has_unescaped_host_var.
    DATA ls_tok            TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_in_into_parens TYPE abap_bool.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_unes = abap_false.

    IF /skyl/cl_ast_util=>match_token_sequence( is_statement = is_statement
                                                   it_expected  = VALUE #( ( `OF` ) ( `TABLE` ) ) ) = abap_true.
      ls_tok = /skyl/cl_ast_util=>get_token_after_sequence( is_statement = is_statement
                                                               it_expected  = VALUE #( ( `OF` ) ( `TABLE` ) ) ).
    ELSEIF /skyl/cl_ast_util=>match_token_sequence( is_statement = is_statement
                                                       it_expected  = VALUE #( ( `FIELDS` ) ( `OF` ) ) ) = abap_true.
      ls_tok = /skyl/cl_ast_util=>get_token_after_sequence( is_statement = is_statement
                                                               it_expected  = VALUE #( ( `FIELDS` ) ( `OF` ) ) ).
    ELSEIF /skyl/cl_ast_util=>match_token_sequence( is_statement = is_statement
                                                       it_expected  = VALUE #( ( `INTO` ) ( `TABLE` ) ) ) = abap_true.
      ls_tok = /skyl/cl_ast_util=>get_token_after_sequence( is_statement = is_statement
                                                               it_expected  = VALUE #( ( `INTO` ) ( `TABLE` ) ) ).
    ELSEIF /skyl/cl_ast_util=>match_token_sequence( is_statement = is_statement
                                                       it_expected  = VALUE #( ( `APPENDING` ) ( `TABLE` ) ) ) = abap_true.
      ls_tok = /skyl/cl_ast_util=>get_token_after_sequence( is_statement = is_statement
                                                               it_expected  = VALUE #( ( `APPENDING` ) ( `TABLE` ) ) ).
    ELSEIF /skyl/cl_ast_util=>has_token_lexeme( is_statement = is_statement
                                                   iv_lexeme    = 'INTO' ) = abap_true.
      ls_tok = /skyl/cl_ast_util=>get_token_after( is_statement = is_statement
                                                      iv_lexeme    = 'INTO' ).
    ENDIF.

    IF ls_tok-lexeme IS INITIAL.
      RETURN.
    ENDIF.

    IF ls_tok-lexeme = '('.
      LOOP AT is_statement-tokens ASSIGNING <ls_token>.
        IF <ls_token>-lexeme = 'INTO'.
          lv_in_into_parens = abap_true.
          CONTINUE.
        ENDIF.

        IF lv_in_into_parens = abap_false.
          CONTINUE.
        ENDIF.

        IF <ls_token>-lexeme = ')'.
          EXIT.
        ENDIF.

        IF <ls_token>-lexeme = '(' OR <ls_token>-lexeme = ','.
          CONTINUE.
        ENDIF.

        IF <ls_token>-lexeme(1) <> '@'.
          rv_unes = abap_true.
          RETURN.
        ENDIF.
      ENDLOOP.
      RETURN.
    ENDIF.

    IF ls_tok-lexeme(1) <> '@'.
      rv_unes = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
