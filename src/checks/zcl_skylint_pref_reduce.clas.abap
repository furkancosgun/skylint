CLASS zcl_skylint_pref_reduce DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_reduce TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_REDUC',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_REDUCE'.

    METHODS is_simple_aggregation_loop
      IMPORTING iv_loop_idx         TYPE i
                it_statements       TYPE if_ci_atc_source_code_provider=>ty_statements
                iv_total            TYPE i
      RETURNING VALUE(rv_is_simple) TYPE abap_bool.

    METHODS is_aggregation_stmt
      IMPORTING is_statement        TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_item_var         TYPE string
      RETURNING VALUE(rv_is_aggreg) TYPE abap_bool.
ENDCLASS.


CLASS zcl_skylint_pref_reduce IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #(
            description       = 'Prefer REDUCE #( ) expression over simple aggregation LOOP'
            remote_enablement = abap_true
            finding_codes     = VALUE #( ( code           = c_finding_codes-prefer_reduce
                                           severity       = if_ci_atc_check=>finding_severities-warning
                                           text           = 'Prefer REDUCE #( ) expression over simple aggregation LOOP'
                                           pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_idx   TYPE i.
    DATA lv_total TYPE i.
    FIELD-SYMBOLS <ls_loop> TYPE if_ci_atc_source_code_provider=>ty_statement.

    lv_total = zcl_skylint_ast_util=>statement_count( is_procedure-statements ).

    LOOP AT is_procedure-statements ASSIGNING <ls_loop>.
      lv_idx = sy-tabix.
      IF <ls_loop>-keyword <> 'LOOP'.
        CONTINUE.
      ENDIF.

      IF is_simple_aggregation_loop( iv_loop_idx   = lv_idx
                                     it_statements = is_procedure-statements
                                     iv_total      = lv_total ) = abap_false.
        CONTINUE.
      ENDIF.

      report_statement( is_statement    = <ls_loop>
                        iv_finding_code = c_finding_codes-prefer_reduce ).
    ENDLOOP.
  ENDMETHOD.

  METHOD is_simple_aggregation_loop.
    DATA ls_loop_stmt  TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_body_stmt  TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_end_stmt   TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA lv_into_pos   TYPE i.
    DATA lv_assign_pos TYPE i.
    DATA lv_target     TYPE string.
    DATA ls_tok        TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_is_simple = abap_false.

    IF iv_loop_idx + 2 > iv_total.
      RETURN.
    ENDIF.

    ls_loop_stmt = zcl_skylint_ast_util=>get_statement( it_statements = it_statements
                                                        iv_index      = iv_loop_idx ).
    ls_body_stmt = zcl_skylint_ast_util=>get_statement( it_statements = it_statements
                                                        iv_index      = iv_loop_idx + 1 ).
    ls_end_stmt  = zcl_skylint_ast_util=>get_statement( it_statements = it_statements
                                                        iv_index      = iv_loop_idx + 2 ).

    IF ls_end_stmt-keyword <> 'ENDLOOP'.
      RETURN.
    ENDIF.

    IF    zcl_skylint_ast_util=>find_token( is_statement = ls_loop_stmt
                                            iv_lexeme    = 'WHERE' )    > 0
       OR zcl_skylint_ast_util=>find_token( is_statement = ls_loop_stmt
                                            iv_lexeme    = 'GROUP' )    > 0.
      RETURN.
    ENDIF.

    IF zcl_skylint_ast_util=>matches_token_at( is_statement = ls_loop_stmt
                                               iv_index     = 2
                                               iv_expected  = `AT` ) = abap_false.
      RETURN.
    ENDIF.

    lv_into_pos   = zcl_skylint_ast_util=>find_token( is_statement = ls_loop_stmt
                                                      iv_lexeme    = 'INTO' ).
    lv_assign_pos = zcl_skylint_ast_util=>find_token( is_statement = ls_loop_stmt
                                                      iv_lexeme    = 'ASSIGNING' ).

    IF lv_into_pos > 0.
      ls_tok = zcl_skylint_ast_util=>get_token( is_statement = ls_loop_stmt
                                                iv_index     = lv_into_pos + 1 ).
      lv_target = zcl_skylint_ast_util=>extract_name_from_paren( ls_tok-lexeme ).
    ELSEIF lv_assign_pos > 0.
      ls_tok = zcl_skylint_ast_util=>get_token( is_statement = ls_loop_stmt
                                                iv_index     = lv_assign_pos + 1 ).
      lv_target = zcl_skylint_ast_util=>extract_name_from_paren( ls_tok-lexeme ).
    ELSE.
      RETURN.
    ENDIF.

    rv_is_simple = is_aggregation_stmt( is_statement = ls_body_stmt
                                        iv_item_var  = lv_target ).
  ENDMETHOD.

  METHOD is_aggregation_stmt.
    DATA lv_tok_count TYPE i.
    DATA ls_first     TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_second    TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_third     TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_found     TYPE abap_bool.
    FIELD-SYMBOLS <ls_tok> TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_is_aggreg = abap_false.

    IF is_statement-keyword <> 'COMPUTE'.
      RETURN.
    ENDIF.

    lv_tok_count = lines( is_statement-tokens ).
    IF lv_tok_count < 3.
      RETURN.
    ENDIF.

    ls_first  = zcl_skylint_ast_util=>get_first_token( is_statement ).
    ls_second = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                 iv_index     = 2 ).
    ls_third  = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                 iv_index     = 3 ).

    IF ls_second-lexeme <> '='.
      RETURN.
    ENDIF.

    lv_found = abap_false.
    LOOP AT is_statement-tokens FROM 3 ASSIGNING <ls_tok>.
      IF <ls_tok>-lexeme = iv_item_var OR <ls_tok>-lexeme CP |{ iv_item_var }-*|.
        lv_found = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF lv_found = abap_false.
      RETURN.
    ENDIF.

    rv_is_aggreg = xsdbool( ls_third-lexeme = ls_first-lexeme ).
  ENDMETHOD.
ENDCLASS.
