CLASS zcl_skylint_no_dynamic_stmt DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        no_dynamic_stuff TYPE if_ci_atc_check=>ty_finding_code VALUE 'DYN_STUFF',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_DYNAMIC'.

    DATA mv_check_dynamic_sql         TYPE abap_bool VALUE abap_true.
    DATA mv_ignore_rap_query_provider TYPE abap_bool VALUE abap_true.

    METHODS is_dynamic_construct
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    METHODS is_dynamic_sql
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_yes) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_no_dynamic_stmt IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'skylint: No Dynamic Constructs (CALL, ASSIGN, CREATE, etc.)'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-no_dynamic_stuff
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Avoid dynamic calls and language constructs'
                                       pseudo_comment = c_pseudo_comment ) )
                                 attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                                              ( name  = 'CHECK_DYNAMIC_SQL'
                                                                value = REF #( mv_check_dynamic_sql ) )
                                                              ( name  = 'IGNORE_RAP_QUERY_PROVIDER'
                                                                value = REF #( mv_ignore_rap_query_provider ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_ignore_dyn_sql TYPE abap_bool.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    lv_ignore_dyn_sql = abap_false.
    IF mv_ignore_rap_query_provider = abap_true AND is_procedure-id-name CP '*IF_RAP_QUERY_PROVIDER~SELECT'.
      lv_ignore_dyn_sql = abap_true.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF is_dynamic_construct( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-no_dynamic_stuff ).
      ELSEIF     mv_check_dynamic_sql             = abap_true
             AND lv_ignore_dyn_sql                = abap_false
             AND is_dynamic_sql( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-no_dynamic_stuff ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_dynamic_construct.
    DATA ls_tok2  TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_after TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_yes = abap_false.

    IF lines( is_statement-tokens ) < 2.
      RETURN.
    ENDIF.

    CASE is_statement-keyword.
      WHEN 'CALL' OR '+CALL_METHOD'.
        IF zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                   iv_lexeme    = 'FUNCTION' ) = abap_true.
          ls_after = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                            iv_lexeme    = 'FUNCTION' ).
          IF ls_after-lexeme IS NOT INITIAL AND zcl_skylint_ast_util=>token_is_literal( ls_after ) = abap_false.
            rv_yes = abap_true.
            RETURN.
          ENDIF.
        ELSEIF is_statement-keyword = '+CALL_METHOD'.
          ls_after = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                      iv_index     = 1 ).
          IF ls_after-lexeme CP '*->(*)*' OR ls_after-lexeme CP '*=>(*)*'.
            rv_yes = abap_true.
            RETURN.
          ENDIF.
        ELSEIF zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                       iv_lexeme    = 'METHOD' ) = abap_true.
          ls_after = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                            iv_lexeme    = 'METHOD' ).
          IF ls_after-lexeme CP '(*)' OR ls_after-lexeme CP '*->(*)*' OR ls_after-lexeme CP '*=>(*)*'.
            rv_yes = abap_true.
            RETURN.
          ENDIF.
        ENDIF.

      WHEN 'ASSIGN'.
        IF zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                   iv_lexeme    = 'COMPONENT' ) = abap_true.
          rv_yes = abap_true.
          RETURN.
        ENDIF.

        ls_tok2 = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                   iv_index     = 2 ).
        IF ls_tok2-lexeme CP '(*)'.
          rv_yes = abap_true.
          RETURN.
        ENDIF.

      WHEN 'CREATE'.
        IF zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                   iv_lexeme    = 'TYPE' ) = abap_true.
          ls_after = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                            iv_lexeme    = 'TYPE' ).
          IF ls_after-lexeme CP '(*)'.
            rv_yes = abap_true.
            RETURN.
          ENDIF.
        ENDIF.

      WHEN 'SUBMIT' OR 'PERFORM'.
        ls_tok2 = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                   iv_index     = 2 ).
        IF ls_tok2-lexeme CP '(*)'.
          rv_yes = abap_true.
          RETURN.
        ENDIF.

      WHEN 'SORT'.
        IF zcl_skylint_ast_util=>has_token_lexeme( is_statement = is_statement
                                                   iv_lexeme    = 'BY' ) = abap_true.
          ls_after = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                            iv_lexeme    = 'BY' ).
          IF ls_after-lexeme CP '(*)'.
            rv_yes = abap_true.
            RETURN.
          ENDIF.
        ENDIF.
    ENDCASE.
  ENDMETHOD.

  METHOD is_dynamic_sql.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_yes = abap_false.

    IF zcl_skylint_ast_util=>statement_is_db_access( is_statement ) = abap_false.
      RETURN.
    ENDIF.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      IF <ls_token>-lexeme CP '(*)' AND <ls_token>-lexeme <> '(*)'.
        rv_yes = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
