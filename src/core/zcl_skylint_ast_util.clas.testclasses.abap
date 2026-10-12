CLASS ltcl_ast_util DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_token_getters           FOR TESTING RAISING cx_static_check.
    METHODS test_statement_getters       FOR TESTING RAISING cx_static_check.
    METHODS test_relative_token_search   FOR TESTING RAISING cx_static_check.
    METHODS test_semantic_helpers        FOR TESTING RAISING cx_static_check.
    METHODS test_keyword_reference_guard FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_ast_util IMPLEMENTATION.
  METHOD test_keyword_reference_guard.
    DATA ls_stmt TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_ref  TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.
    DATA lt_refs TYPE if_ci_atc_source_code_provider=>ty_compiler_references.

    ls_ref = VALUE #( kind       = if_ci_atc_source_code_provider=>compiler_reference_kinds-data
                      usage_mode = if_ci_atc_source_code_provider=>usage_modes-read ).
    lt_refs = VALUE #( ( ls_ref ) ).

    " Token 'EXPORTING' with compiler reference (e.g. variable named 'exporting')
    ls_stmt = VALUE #( keyword = 'CALL'
                       tokens  = VALUE #( ( lexeme = 'CALL' )
                                          ( lexeme     = 'exporting'
                                            references = lt_refs ) ) ).

    cl_abap_unit_assert=>assert_false( zcl_skylint_ast_util=>has_token_lexeme( is_statement = ls_stmt
                                                                               iv_lexeme    = 'EXPORTING' ) ).
    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = zcl_skylint_ast_util=>find_token( is_statement = ls_stmt
                                                                                iv_lexeme    = 'EXPORTING' ) ).
    cl_abap_unit_assert=>assert_false( zcl_skylint_ast_util=>matches_token_at( is_statement = ls_stmt
                                                                               iv_index     = 2
                                                                               iv_expected  = 'EXPORTING' ) ).

    " True keyword 'EXPORTING' with empty references IS matched
    ls_stmt = VALUE #( keyword = 'CALL'
                       tokens  = VALUE #( ( lexeme = 'CALL' )
                                          ( lexeme = 'EXPORTING' ) ) ).

    cl_abap_unit_assert=>assert_true( zcl_skylint_ast_util=>has_token_lexeme( is_statement = ls_stmt
                                                                              iv_lexeme    = 'EXPORTING' ) ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = zcl_skylint_ast_util=>find_token( is_statement = ls_stmt
                                                                                iv_lexeme    = 'EXPORTING' ) ).
  ENDMETHOD.

  METHOD test_token_getters.
    DATA ls_stmt TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_tok  TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_lex  TYPE string.

    ls_stmt = VALUE #( keyword = 'DATA'
                       tokens  = VALUE #( ( lexeme = 'DATA' )
                                          ( lexeme = 'lv_a' )
                                          ( lexeme = 'TYPE' )
                                          ( lexeme = 'i' ) ) ).

    cl_abap_unit_assert=>assert_equals( exp = 4
                                        act = zcl_skylint_ast_util=>token_count( ls_stmt ) ).

    ls_tok = zcl_skylint_ast_util=>get_token( is_statement = ls_stmt
                                              iv_index     = 1 ).
    cl_abap_unit_assert=>assert_equals( exp = 'DATA'
                                        act = ls_tok-lexeme ).

    ls_tok = zcl_skylint_ast_util=>get_token( is_statement = ls_stmt
                                              iv_index     = 99 ).
    cl_abap_unit_assert=>assert_initial( ls_tok-lexeme ).

    ls_tok = zcl_skylint_ast_util=>get_first_token( ls_stmt ).
    cl_abap_unit_assert=>assert_equals( exp = 'DATA'
                                        act = ls_tok-lexeme ).

    ls_tok = zcl_skylint_ast_util=>get_last_token( ls_stmt ).
    cl_abap_unit_assert=>assert_equals( exp = 'i'
                                        act = ls_tok-lexeme ).

    lv_lex = zcl_skylint_ast_util=>get_token_lexeme( is_statement = ls_stmt
                                                     iv_index     = 4 ).
    cl_abap_unit_assert=>assert_equals( exp = 'I'
                                        act = lv_lex ).
  ENDMETHOD.

  METHOD test_statement_getters.
    DATA lt_stmts TYPE if_ci_atc_source_code_provider=>ty_statements.
    DATA ls_curr  TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_next  TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_prev  TYPE if_ci_atc_source_code_provider=>ty_statement.

    lt_stmts = VALUE #( ( keyword = 'DATA' )
                        ( keyword = 'COMPUTE' )
                        ( keyword = 'RETURN' ) ).

    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = zcl_skylint_ast_util=>statement_count( lt_stmts ) ).

    ls_curr = zcl_skylint_ast_util=>get_statement( it_statements = lt_stmts
                                                   iv_index      = 1 ).
    cl_abap_unit_assert=>assert_equals( exp = 'DATA'
                                        act = ls_curr-keyword ).

    ls_next = zcl_skylint_ast_util=>get_next_statement( it_statements    = lt_stmts
                                                        iv_current_index = 1 ).
    cl_abap_unit_assert=>assert_equals( exp = 'COMPUTE'
                                        act = ls_next-keyword ).

    ls_prev = zcl_skylint_ast_util=>get_previous_statement( it_statements    = lt_stmts
                                                            iv_current_index = 2 ).
    cl_abap_unit_assert=>assert_equals( exp = 'DATA'
                                        act = ls_prev-keyword ).
  ENDMETHOD.

  METHOD test_relative_token_search.
    DATA ls_stmt TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_tok  TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_idx  TYPE i.

    ls_stmt = VALUE #( keyword = 'SELECT'
                       tokens  = VALUE #( ( lexeme = 'SELECT' )
                                          ( lexeme = '*' )
                                          ( lexeme = 'FROM' )
                                          ( lexeme = 'sflight' )
                                          ( lexeme = 'INTO' )
                                          ( lexeme = 'TABLE' )
                                          ( lexeme = '@DATA(lt_res)' ) ) ).

    lv_idx = zcl_skylint_ast_util=>find_token( is_statement = ls_stmt
                                               iv_lexeme    = 'FROM' ).
    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lv_idx ).

    ls_tok = zcl_skylint_ast_util=>get_token_after( is_statement = ls_stmt
                                                    iv_lexeme    = 'FROM' ).
    cl_abap_unit_assert=>assert_equals( exp = 'SFLIGHT'
                                        act = ls_tok-lexeme  ).

    ls_tok = zcl_skylint_ast_util=>get_token_before( is_statement = ls_stmt
                                                     iv_lexeme    = 'FROM' ).
    cl_abap_unit_assert=>assert_equals( exp = '*'
                                        act = ls_tok-lexeme ).

    ls_tok = zcl_skylint_ast_util=>get_token_after_sequence( is_statement = ls_stmt
                                                             it_expected  = VALUE #( ( `INTO` ) ( `TABLE` ) ) ).
    cl_abap_unit_assert=>assert_equals( exp = '@DATA(lt_res)'
                                        act = ls_tok-lexeme ).
  ENDMETHOD.

  METHOD test_semantic_helpers.
    DATA ls_stmt TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_tok  TYPE if_ci_atc_source_code_provider=>ty_token.

    ls_stmt = VALUE #( keyword = 'COMPUTE'
                       tokens  = VALUE #( ( lexeme = 'lv_x' )
                                          ( lexeme = '=' )
                                          ( lexeme = `'ABC'` ) ) ).

    cl_abap_unit_assert=>assert_true( zcl_skylint_ast_util=>is_assignment( ls_stmt ) ).

    ls_tok = zcl_skylint_ast_util=>get_token( is_statement = ls_stmt
                                              iv_index     = 1 ).
    cl_abap_unit_assert=>assert_true( zcl_skylint_ast_util=>token_is_identifier( ls_tok ) ).

    ls_tok = zcl_skylint_ast_util=>get_token( is_statement = ls_stmt
                                              iv_index     = 2 ).
    cl_abap_unit_assert=>assert_true( zcl_skylint_ast_util=>is_comparison_operator( ls_tok-lexeme ) ).

    ls_tok = zcl_skylint_ast_util=>get_token( is_statement = ls_stmt
                                              iv_index     = 3 ).
    cl_abap_unit_assert=>assert_true( zcl_skylint_ast_util=>token_is_literal( ls_tok ) ).
  ENDMETHOD.
ENDCLASS.
