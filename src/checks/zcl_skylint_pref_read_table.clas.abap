CLASS zcl_skylint_pref_read_table DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_tab_expr    TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_TABEX',
        prefer_line_exists TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_LNEXS',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment_expr TYPE string VALUE 'PREF_TABLE_EXPR'.
    CONSTANTS c_pseudo_comment_line TYPE string VALUE 'PREF_LINE_EXISTS'.

    DATA mv_check_tab_expr    TYPE abap_bool VALUE abap_true.
    DATA mv_check_line_exists TYPE abap_bool VALUE abap_true.

    METHODS is_table_expr_candidate
      IMPORTING is_statement           TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_is_candidate) TYPE abap_bool.

    METHODS find_clause_end
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_start      TYPE i
                iv_max        TYPE i
                it_keywords   TYPE string_table
      RETURNING VALUE(rv_end) TYPE i.

    METHODS has_transporting_no_fields
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_has) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_pref_read_table IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Modernize READ TABLE (table expressions & line_exists)'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     severity = if_ci_atc_check=>finding_severities-warning
                     ( code           = c_finding_codes-prefer_tab_expr
                       text           = 'Prefer table expression itab[ ... ] over READ TABLE'
                       pseudo_comment = c_pseudo_comment_expr )
                     ( code           = c_finding_codes-prefer_line_exists
                       text           = 'Prefer line_exists( ... ) instead of READ TABLE ... TRANSPORTING NO FIELDS'
                       pseudo_comment = c_pseudo_comment_line ) )
                 attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                              ( name  = 'CHECK_TAB_EXPR'
                                                value = REF #( mv_check_tab_expr ) )
                                              ( name  = 'CHECK_LINE_EXISTS'
                                                value = REF #( mv_check_line_exists ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF     mv_check_line_exists = abap_true
         AND ( <ls_statement>-keyword = 'READ' OR <ls_statement>-keyword = 'LOOP' )
         AND has_transporting_no_fields( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-prefer_line_exists ).
        CONTINUE.
      ENDIF.

      IF NOT ( mv_check_tab_expr = abap_true AND <ls_statement>-keyword = 'READ' ).
        CONTINUE.
      ENDIF.

      IF is_table_expr_candidate( <ls_statement> ) = abap_true.
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-prefer_tab_expr ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_table_expr_candidate.
    DATA lv_tokens_cnt   TYPE i.
    DATA lv_into_pos     TYPE i.
    DATA lv_assign_pos   TYPE i.
    DATA lv_ref_pos      TYPE i.
    DATA lv_target_start TYPE i.
    DATA lv_key_pos      TYPE i.
    DATA lv_index_pos    TYPE i.
    DATA lv_cond_start   TYPE i.
    DATA lv_cond_end     TYPE i.
    DATA lt_cond_terms   TYPE string_table.

    rv_is_candidate = abap_false.
    lv_tokens_cnt = lines( is_statement-tokens ).
    IF lv_tokens_cnt < 4.
      RETURN.
    ENDIF.

    IF zcl_skylint_ast_util=>matches_token_at( is_statement = is_statement
                                               iv_index     = 2
                                               iv_expected  = `TABLE` ) = abap_false.
      RETURN.
    ENDIF.

    IF zcl_skylint_ast_util=>find_token_sequence( is_statement = is_statement
                                                  it_expected  = VALUE #( ( `BINARY` ) ( `SEARCH` ) ) ) > 0.
      RETURN.
    ENDIF.

    IF zcl_skylint_ast_util=>find_token_sequence( is_statement = is_statement
                                                  it_expected  = VALUE #( ( `TRANSPORTING` ) ( `NO` ) ( `FIELDS` ) ) ) > 0.
      RETURN.
    ENDIF.

    lv_into_pos   = zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                      iv_lexeme    = 'INTO' ).
    lv_assign_pos = zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                      iv_lexeme    = 'ASSIGNING' ).
    lv_ref_pos    = zcl_skylint_ast_util=>find_token_sequence( is_statement = is_statement
                                                               it_expected  = VALUE #( ( `REFERENCE` ) ( `INTO` ) ) ).

    IF lv_into_pos > 0.
      lv_target_start = lv_into_pos + 1.
    ELSEIF lv_assign_pos > 0.
      lv_target_start = lv_assign_pos + 1.
    ELSEIF lv_ref_pos > 0.
      lv_target_start = lv_ref_pos + 2.
    ELSE.
      RETURN.
    ENDIF.

    IF lv_target_start > lv_tokens_cnt.
      RETURN.
    ENDIF.

    lv_index_pos = zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                     iv_lexeme    = 'INDEX' ).
    lv_key_pos   = zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                     iv_lexeme    = 'WITH' ).

    lt_cond_terms = VALUE #( ( `INTO` ) ( `ASSIGNING` ) ( `REFERENCE` ) ( `BINARY` ) ( `TRANSPORTING` ) ).

    IF lv_index_pos > 0 AND lv_index_pos < lv_tokens_cnt.
      lv_cond_start = lv_index_pos + 1.
      lv_cond_end   = find_clause_end( is_statement = is_statement
                                       iv_start     = lv_cond_start
                                       iv_max       = lv_tokens_cnt
                                       it_keywords  = lt_cond_terms ).
      IF lv_cond_end >= lv_cond_start.
        rv_is_candidate = abap_true.
      ENDIF.
    ELSEIF lv_key_pos > 0.
      IF zcl_skylint_ast_util=>matches_token_at( is_statement = is_statement
                                                 iv_index     = lv_key_pos + 1
                                                 iv_expected  = `KEY` ) = abap_true.
        lv_cond_start = lv_key_pos + 2.
      ELSEIF     zcl_skylint_ast_util=>matches_token_at( is_statement = is_statement
                                                         iv_index     = lv_key_pos + 1
                                                         iv_expected  = `TABLE` )      = abap_true
             AND zcl_skylint_ast_util=>matches_token_at( is_statement = is_statement
                                                         iv_index     = lv_key_pos + 2
                                                         iv_expected  = `KEY` )        = abap_true.
        lv_cond_start = lv_key_pos + 3.
      ENDIF.

      IF lv_cond_start > 0 AND lv_cond_start <= lv_tokens_cnt.
        lv_cond_end = find_clause_end( is_statement = is_statement
                                       iv_start     = lv_cond_start
                                       iv_max       = lv_tokens_cnt
                                       it_keywords  = lt_cond_terms ).
        IF lv_cond_end >= lv_cond_start.
          rv_is_candidate = abap_true.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD find_clause_end.
    DATA lv_idx   TYPE i.
    DATA lv_depth TYPE i.
    DATA ls_tok   TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_end = iv_max.
    lv_idx = iv_start.
    lv_depth = 0.
    WHILE lv_idx <= iv_max.
      ls_tok = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                iv_index     = lv_idx ).
      IF     lv_depth           = 0
         AND ls_tok-references IS INITIAL
         AND line_exists( it_keywords[ table_line = ls_tok-lexeme ] ).
        rv_end = lv_idx - 1.
        RETURN.
      ENDIF.
      lv_depth += zcl_skylint_ast_util=>token_paren_delta( ls_tok ).
      lv_idx += 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD has_transporting_no_fields.
    rv_has = abap_false.

    IF zcl_skylint_ast_util=>find_token_sequence( is_statement = is_statement
                                                  it_expected  = VALUE #( ( `BINARY` ) ( `SEARCH` ) ) ) > 0.
      RETURN.
    ENDIF.

    IF zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                         iv_lexeme    = 'WHERE' ) > 0.
      RETURN.
    ENDIF.

    IF zcl_skylint_ast_util=>find_token_sequence( is_statement = is_statement
                                                  it_expected  = VALUE #( ( `TRANSPORTING` ) ( `NO` ) ( `FIELDS` ) ) ) > 0.
      rv_has = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
