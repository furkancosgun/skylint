CLASS ltcl_ast_util DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_token_getters          FOR TESTING RAISING cx_static_check.
    METHODS test_statement_getters      FOR TESTING RAISING cx_static_check.
    METHODS test_relative_token_search  FOR TESTING RAISING cx_static_check.
    METHODS test_semantic_helpers       FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_ast_util IMPLEMENTATION.

  METHOD test_token_getters.
    DATA ls_stmt TYPE zif_skylint_types=>ty_statement.
    DATA ls_tok  TYPE zif_skylint_types=>ty_token.
    DATA lv_lex  TYPE string.

    ls_stmt = VALUE #(
        keyword = 'DATA'
        tokens  = VALUE #(
            ( lexeme = 'DATA' )
            ( lexeme = 'lv_a' )
            ( lexeme = 'TYPE' )
            ( lexeme = 'i' ) ) ).

    cl_abap_unit_assert=>assert_equals( act = zcl_skylint_ast_util=>token_count( ls_stmt )
                                        exp = 4 ).

    ls_tok = zcl_skylint_ast_util=>get_token( is_statement = ls_stmt
                                              iv_index     = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_tok-lexeme
                                        exp = 'DATA' ).

    ls_tok = zcl_skylint_ast_util=>get_token( is_statement = ls_stmt
                                              iv_index     = 99 ).
    cl_abap_unit_assert=>assert_initial( ls_tok-lexeme ).

    ls_tok = zcl_skylint_ast_util=>get_first_token( ls_stmt ).
    cl_abap_unit_assert=>assert_equals( act = ls_tok-lexeme
                                        exp = 'DATA' ).

    ls_tok = zcl_skylint_ast_util=>get_last_token( ls_stmt ).
    cl_abap_unit_assert=>assert_equals( act = ls_tok-lexeme
                                        exp = 'i' ).

    lv_lex = zcl_skylint_ast_util=>get_token_lexeme( is_statement = ls_stmt
                                                     iv_index     = 4 ).
    cl_abap_unit_assert=>assert_equals( act = lv_lex
                                        exp = 'I' ).
  ENDMETHOD.

  METHOD test_statement_getters.
    DATA lt_stmts TYPE zif_skylint_types=>ty_statements.
    DATA ls_curr  TYPE zif_skylint_types=>ty_statement.
    DATA ls_next  TYPE zif_skylint_types=>ty_statement.
    DATA ls_prev  TYPE zif_skylint_types=>ty_statement.

    lt_stmts = VALUE #(
        ( keyword = 'DATA' )
        ( keyword = 'COMPUTE' )
        ( keyword = 'RETURN' ) ).

    cl_abap_unit_assert=>assert_equals( act = zcl_skylint_ast_util=>statement_count( lt_stmts )
                                        exp = 3 ).

    ls_curr = zcl_skylint_ast_util=>get_statement( it_statements = lt_stmts
                                                   iv_index      = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_curr-keyword
                                        exp = 'DATA' ).

    ls_next = zcl_skylint_ast_util=>get_next_statement( it_statements    = lt_stmts
                                                        iv_current_index = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_next-keyword
                                        exp = 'COMPUTE' ).

    ls_prev = zcl_skylint_ast_util=>get_previous_statement( it_statements    = lt_stmts
                                                            iv_current_index = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_prev-keyword
                                        exp = 'DATA' ).
  ENDMETHOD.

  METHOD test_relative_token_search.
    DATA ls_stmt TYPE zif_skylint_types=>ty_statement.
    DATA ls_tok  TYPE zif_skylint_types=>ty_token.
    DATA lv_idx  TYPE i.

    ls_stmt = VALUE #(
        keyword = 'SELECT'
        tokens  = VALUE #(
            ( lexeme = 'SELECT' )
            ( lexeme = '*' )
            ( lexeme = 'FROM' )
            ( lexeme = 'sflight' )
            ( lexeme = 'INTO' )
            ( lexeme = 'TABLE' )
            ( lexeme = '@DATA(lt_res)' ) ) ).

    lv_idx = zcl_skylint_ast_util=>find_token( is_statement = ls_stmt
                                               iv_lexeme    = 'FROM' ).
    cl_abap_unit_assert=>assert_equals( act = lv_idx
                                        exp = 3 ).

    ls_tok = zcl_skylint_ast_util=>get_token_after( is_statement = ls_stmt
                                                    iv_lexeme    = 'FROM' ).
    cl_abap_unit_assert=>assert_equals( act = to_upper( ls_tok-lexeme )
                                        exp = 'SFLIGHT' ).

    ls_tok = zcl_skylint_ast_util=>get_token_before( is_statement = ls_stmt
                                                     iv_lexeme    = 'FROM' ).
    cl_abap_unit_assert=>assert_equals( act = ls_tok-lexeme
                                        exp = '*' ).

    ls_tok = zcl_skylint_ast_util=>get_token_after_sequence(
        is_statement = ls_stmt
        it_expected  = VALUE #( ( `INTO` ) ( `TABLE` ) ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_tok-lexeme
                                        exp = '@DATA(lt_res)' ).
  ENDMETHOD.

  METHOD test_semantic_helpers.
    DATA ls_stmt TYPE zif_skylint_types=>ty_statement.
    DATA ls_tok  TYPE zif_skylint_types=>ty_token.

    ls_stmt = VALUE #(
        keyword = 'COMPUTE'
        type    = zif_skylint_types=>statement_types-compute
        tokens  = VALUE #(
            ( lexeme = 'lv_x' type = zif_skylint_types=>token_types-identifier )
            ( lexeme = '='    type = zif_skylint_types=>token_types-identifier )
            ( lexeme = `'ABC'` type = zif_skylint_types=>token_types-literal ) ) ).

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
