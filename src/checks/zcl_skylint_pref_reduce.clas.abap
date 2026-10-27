CLASS zcl_skylint_pref_reduce DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_reduce TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_REDUC',
      END OF c_finding_codes.

    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        use_reduce TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'USEREDUCE',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_REDUCE'.

    TYPES:
      BEGIN OF ty_loop_info,
        table_name  TYPE string,
        target_name TYPE string,
        is_assign   TYPE abap_bool,
        acc_var     TYPE string,
        body_stmt   TYPE if_ci_atc_source_code_provider=>ty_statement,
        is_valid    TYPE abap_bool,
      END OF ty_loop_info.

    METHODS parse_simple_loop
      IMPORTING iv_loop_idx    TYPE i
                it_statements  TYPE if_ci_atc_source_code_provider=>ty_statements
                iv_total       TYPE i
      EXPORTING es_info        TYPE ty_loop_info
                ev_endloop_idx TYPE i.

    METHODS parse_aggregation_stmt
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_item_var  TYPE string
      EXPORTING ev_acc_var   TYPE string
                ev_is_valid  TYPE abap_bool.

    METHODS build_reduce_code
      IMPORTING is_loop_stmt   TYPE if_ci_atc_source_code_provider=>ty_statement
                is_info        TYPE ty_loop_info
      RETURNING VALUE(rt_code) TYPE zcl_skylint_check_base=>ty_code_lines.

    METHODS build_reduce_expr
      IMPORTING is_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_from        TYPE i
                iv_to          TYPE i
                iv_acc_var     TYPE string
      RETURNING VALUE(rv_expr) TYPE string.

    METHODS clean_target_name
      IMPORTING iv_raw          TYPE string
      RETURNING VALUE(rv_clean) TYPE string.

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
                                           pseudo_comment = c_pseudo_comment ) )
            quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-use_reduce
                                           short_text = 'Replace LOOP with REDUCE #( )' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_idx         TYPE i.
    DATA lv_total       TYPE i.
    DATA ls_info        TYPE ty_loop_info.
    DATA lv_endloop_idx TYPE i.
    DATA ls_quickfix    TYPE zcl_skylint_check_base=>ty_quickfix.
    DATA lt_new_code    TYPE zcl_skylint_check_base=>ty_code_lines.
    FIELD-SYMBOLS <ls_loop> TYPE if_ci_atc_source_code_provider=>ty_statement.

    lv_total = zcl_skylint_ast_util=>statement_count( is_procedure-statements ).

    LOOP AT is_procedure-statements ASSIGNING <ls_loop>.
      IF <ls_loop>-keyword <> 'LOOP'.
        CONTINUE.
      ENDIF.

      lv_idx = sy-tabix.

      parse_simple_loop( EXPORTING iv_loop_idx    = lv_idx
                                   it_statements  = is_procedure-statements
                                   iv_total       = lv_total
                         IMPORTING es_info        = ls_info
                                   ev_endloop_idx = lv_endloop_idx ).

      IF ls_info-is_valid = abap_false OR lv_endloop_idx = 0.
        CONTINUE.
      ENDIF.

      lt_new_code = build_reduce_code( is_loop_stmt = <ls_loop>
                                       is_info      = ls_info ).

      ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-use_reduce
                                      iv_statement_from = lv_idx
                                      iv_statement_to   = lv_endloop_idx
                                      it_new_code       = lt_new_code ).

      report_statement( is_statement    = <ls_loop>
                        iv_finding_code = c_finding_codes-prefer_reduce
                        is_quickfix     = ls_quickfix ).
    ENDLOOP.
  ENDMETHOD.

  METHOD parse_simple_loop.
    DATA ls_loop_stmt  TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_body_stmt  TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_end_stmt   TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA lv_into_pos   TYPE i.
    DATA lv_assign_pos TYPE i.
    DATA lv_where_pos  TYPE i.
    DATA lv_grp_pos    TYPE i.
    DATA ls_tok        TYPE if_ci_atc_source_code_provider=>ty_token.

    CLEAR: es_info,
           ev_endloop_idx.

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

    lv_where_pos = zcl_skylint_ast_util=>find_token( is_statement = ls_loop_stmt
                                                     iv_lexeme    = 'WHERE' ).
    lv_grp_pos   = zcl_skylint_ast_util=>find_token( is_statement = ls_loop_stmt
                                                     iv_lexeme    = 'GROUP' ).
    IF lv_where_pos > 0 OR lv_grp_pos > 0.
      RETURN.
    ENDIF.

    IF zcl_skylint_ast_util=>matches_token_at( is_statement = ls_loop_stmt
                                               iv_index     = 2
                                               iv_expected  = `AT` ) = abap_false.
      RETURN.
    ENDIF.

    ls_tok = zcl_skylint_ast_util=>get_token_after( is_statement = ls_loop_stmt
                                                    iv_lexeme    = 'AT' ).
    es_info-table_name = ls_tok-lexeme.

    lv_into_pos   = zcl_skylint_ast_util=>find_token( is_statement = ls_loop_stmt
                                                      iv_lexeme    = 'INTO' ).
    lv_assign_pos = zcl_skylint_ast_util=>find_token( is_statement = ls_loop_stmt
                                                      iv_lexeme    = 'ASSIGNING' ).

    IF lv_into_pos > 0.
      ls_tok = zcl_skylint_ast_util=>get_token( is_statement = ls_loop_stmt
                                                iv_index     = lv_into_pos + 1 ).
      es_info-target_name = clean_target_name( ls_tok-lexeme ).
    ELSEIF lv_assign_pos > 0.
      es_info-is_assign = abap_true.
      ls_tok = zcl_skylint_ast_util=>get_token( is_statement = ls_loop_stmt
                                                iv_index     = lv_assign_pos + 1 ).
      es_info-target_name = clean_target_name( ls_tok-lexeme ).
    ELSE.
      RETURN.
    ENDIF.

    parse_aggregation_stmt( EXPORTING is_statement = ls_body_stmt
                                      iv_item_var  = es_info-target_name
                            IMPORTING ev_acc_var   = es_info-acc_var
                                      ev_is_valid  = es_info-is_valid ).

    IF es_info-is_valid = abap_true.
      es_info-body_stmt = ls_body_stmt.
      ev_endloop_idx    = iv_loop_idx + 2.
    ENDIF.
  ENDMETHOD.

  METHOD parse_aggregation_stmt.
    DATA lv_tok_count TYPE i.
    DATA ls_first     TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_second    TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_third     TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_found     TYPE abap_bool.
    FIELD-SYMBOLS <ls_tok> TYPE if_ci_atc_source_code_provider=>ty_token.

    CLEAR: ev_acc_var,
           ev_is_valid.

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

    IF ls_third-lexeme = ls_first-lexeme.
      ev_acc_var  = ls_first-lexeme.
      ev_is_valid = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD clean_target_name.
    rv_clean = zcl_skylint_ast_util=>extract_name_from_paren( iv_raw ).
  ENDMETHOD.

  METHOD build_reduce_code.
    DATA ls_first_tok TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_indent    TYPE string.
    DATA lv_replaced  TYPE string.
    DATA lv_tok_count TYPE i.

    CLEAR rt_code.
    ls_first_tok = zcl_skylint_ast_util=>get_first_token( is_loop_stmt ).
    IF ls_first_tok-position-column > 1.
      lv_indent = repeat( val = ` `
                          occ = ls_first_tok-position-column - 1 ).
    ENDIF.

    lv_tok_count = lines( is_info-body_stmt-tokens ).
    lv_replaced = build_reduce_expr( is_statement = is_info-body_stmt
                                     iv_from      = 3
                                     iv_to        = lv_tok_count
                                     iv_acc_var   = is_info-acc_var ).

    APPEND |{ lv_indent }{ is_info-acc_var } = REDUCE #( | TO rt_code.
    APPEND |{ lv_indent }  INIT res = { is_info-acc_var }| TO rt_code.
    APPEND |{ lv_indent }  FOR { is_info-target_name } IN { is_info-table_name }| TO rt_code.
    APPEND |{ lv_indent }  NEXT res = { lv_replaced } ).| TO rt_code.
  ENDMETHOD.

  METHOD build_reduce_expr.
    DATA ls_prev TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_part TYPE string.
    FIELD-SYMBOLS <ls_tok> TYPE if_ci_atc_source_code_provider=>ty_token.

    LOOP AT is_statement-tokens FROM iv_from TO iv_to ASSIGNING <ls_tok>.
      CLEAR ls_prev.
      IF sy-tabix > iv_from.
        ls_prev = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                   iv_index     = sy-tabix - 1 ).
      ENDIF.

      IF <ls_tok>-lexeme = iv_acc_var AND ls_prev-lexeme <> '-' AND ls_prev-lexeme <> '->'.
        lv_part = 'res'.
      ELSE.
        lv_part = <ls_tok>-lexeme.
      ENDIF.

      IF rv_expr IS INITIAL.
        rv_expr = lv_part.
      ELSEIF lv_part = '-' OR lv_part = '->' OR lv_part = '=>'.
        rv_expr = |{ rv_expr }{ lv_part }|.
      ELSEIF ls_prev-lexeme = '-' OR ls_prev-lexeme = '->' OR ls_prev-lexeme = '=>'.
        rv_expr = |{ rv_expr }{ lv_part }|.
      ELSE.
        rv_expr = |{ rv_expr } { lv_part }|.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
