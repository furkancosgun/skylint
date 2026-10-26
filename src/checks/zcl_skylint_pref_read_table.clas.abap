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

    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        use_tab_expr TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'USETABEXP',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment_expr TYPE string VALUE 'PREF_TABLE_EXPR'.
    CONSTANTS c_pseudo_comment_line TYPE string VALUE 'PREF_LINE_EXISTS'.

    DATA mv_use_optional      TYPE abap_bool VALUE abap_true.
    DATA mv_check_tab_expr    TYPE abap_bool VALUE abap_true.
    DATA mv_check_line_exists TYPE abap_bool VALUE abap_true.

    TYPES:
      BEGIN OF ty_read_table_info,
        table_name  TYPE string,
        target_name TYPE string,
        is_assign   TYPE abap_bool,
        is_ref      TYPE abap_bool,
        is_index    TYPE abap_bool,
        cond_text   TYPE string,
        is_valid    TYPE abap_bool,
      END OF ty_read_table_info.

    METHODS parse_read_table
      IMPORTING is_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rs_info) TYPE ty_read_table_info.

    METHODS extract_tokens_text
      IMPORTING is_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_from_idx    TYPE i
                iv_to_idx      TYPE i
      RETURNING VALUE(rv_text) TYPE string.

    METHODS find_clause_end
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_start      TYPE i
                iv_max        TYPE i
                it_keywords   TYPE string_table
      RETURNING VALUE(rv_end) TYPE i.

    METHODS build_tab_expr_code
      IMPORTING is_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
                is_info        TYPE ty_read_table_info
      RETURNING VALUE(rt_code) TYPE zcl_skylint_check_base=>ty_code_lines.

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
                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-use_tab_expr
                                                short_text = 'Replace READ TABLE with table expression' ) )
                 attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                              ( name  = 'USE_OPTIONAL'
                                                value = REF #( mv_use_optional ) )
                                              ( name  = 'CHECK_TAB_EXPR'
                                                value = REF #( mv_check_tab_expr ) )
                                              ( name  = 'CHECK_LINE_EXISTS'
                                                value = REF #( mv_check_line_exists ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA ls_info     TYPE ty_read_table_info.
    DATA ls_quickfix TYPE zcl_skylint_check_base=>ty_quickfix.
    DATA lt_new_code TYPE zcl_skylint_check_base=>ty_code_lines.
    DATA lv_stmt_idx TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_stmt_idx = sy-tabix.

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

      ls_info = parse_read_table( <ls_statement> ).
      IF ls_info-is_valid = abap_true.
        lt_new_code = build_tab_expr_code( is_statement = <ls_statement>
                                           is_info      = ls_info ).

        ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-use_tab_expr
                                        iv_statement_from = lv_stmt_idx
                                        it_new_code       = lt_new_code ).

        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-prefer_tab_expr
                          is_quickfix     = ls_quickfix ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD parse_read_table.
    DATA lv_into_pos     TYPE i.
    DATA lv_assign_pos   TYPE i.
    DATA lv_ref_pos      TYPE i.
    DATA lv_target_start TYPE i.
    DATA lv_target_end   TYPE i.
    DATA lv_key_pos      TYPE i.
    DATA lv_index_pos    TYPE i.
    DATA lv_bin_pos      TYPE i.
    DATA lv_no_fld_pos   TYPE i.
    DATA lv_tokens_cnt   TYPE i.
    DATA lv_cond_start   TYPE i.
    DATA lv_cond_end     TYPE i.
    DATA ls_tok          TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lt_cond_terms   TYPE string_table.
    DATA lt_target_terms TYPE string_table.

    CLEAR rs_info.
    lv_tokens_cnt = lines( is_statement-tokens ).
    IF lv_tokens_cnt < 4.
      RETURN.
    ENDIF.

    IF zcl_skylint_ast_util=>matches_token_at( is_statement = is_statement
                                               iv_index     = 2
                                               iv_expected  = `TABLE` ) = abap_false.
      RETURN.
    ENDIF.

    lv_bin_pos = zcl_skylint_ast_util=>find_token_sequence( is_statement = is_statement
                                                            it_expected  = VALUE #( ( `BINARY` ) ( `SEARCH` ) ) ).
    IF lv_bin_pos > 0.
      RETURN.
    ENDIF.

    lv_no_fld_pos = zcl_skylint_ast_util=>find_token_sequence(
                        is_statement = is_statement
                        it_expected  = VALUE #( ( `TRANSPORTING` ) ( `NO` ) ( `FIELDS` ) ) ).
    IF lv_no_fld_pos > 0.
      RETURN.
    ENDIF.

    ls_tok = zcl_skylint_ast_util=>get_token_after( is_statement = is_statement
                                                    iv_lexeme    = 'TABLE' ).
    rs_info-table_name = ls_tok-lexeme.

    lv_into_pos   = zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                      iv_lexeme    = 'INTO' ).
    lv_assign_pos = zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                      iv_lexeme    = 'ASSIGNING' ).
    lv_ref_pos    = zcl_skylint_ast_util=>find_token_sequence( is_statement = is_statement
                                                               it_expected  = VALUE #( ( `REFERENCE` ) ( `INTO` ) ) ).

    IF lv_into_pos > 0.
      lv_target_start = lv_into_pos + 1.
    ELSEIF lv_assign_pos > 0.
      rs_info-is_assign = abap_true.
      lv_target_start = lv_assign_pos + 1.
    ELSEIF lv_ref_pos > 0.
      rs_info-is_ref = abap_true.
      lv_target_start = lv_ref_pos + 2.
    ELSE.
      RETURN.
    ENDIF.

    lt_target_terms = VALUE #( ( `WITH` ) ( `INDEX` ) ( `BINARY` ) ( `TRANSPORTING` ) ).
    lv_target_end = find_clause_end( is_statement = is_statement
                                     iv_start     = lv_target_start
                                     iv_max       = lv_tokens_cnt
                                     it_keywords  = lt_target_terms ).
    IF lv_target_end < lv_target_start.
      RETURN.
    ENDIF.
    rs_info-target_name = extract_tokens_text( is_statement = is_statement
                                               iv_from_idx  = lv_target_start
                                               iv_to_idx    = lv_target_end ).

    lv_index_pos = zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                     iv_lexeme    = 'INDEX' ).
    lv_key_pos   = zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                     iv_lexeme    = 'WITH' ).

    lt_cond_terms = VALUE #( ( `INTO` ) ( `ASSIGNING` ) ( `REFERENCE` ) ( `BINARY` ) ( `TRANSPORTING` ) ).

    IF lv_index_pos > 0 AND lv_index_pos < lv_tokens_cnt.
      rs_info-is_index = abap_true.
      lv_cond_start    = lv_index_pos + 1.
      lv_cond_end      = find_clause_end( is_statement = is_statement
                                          iv_start     = lv_cond_start
                                          iv_max       = lv_tokens_cnt
                                          it_keywords  = lt_cond_terms ).
      IF lv_cond_end >= lv_cond_start.
        rs_info-cond_text = extract_tokens_text( is_statement = is_statement
                                                 iv_from_idx  = lv_cond_start
                                                 iv_to_idx    = lv_cond_end ).
        rs_info-is_valid  = abap_true.
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
          rs_info-cond_text = extract_tokens_text( is_statement = is_statement
                                                   iv_from_idx  = lv_cond_start
                                                   iv_to_idx    = lv_cond_end ).
          rs_info-is_valid  = abap_true.
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

  METHOD extract_tokens_text.
    DATA lv_curr_idx TYPE i.
    DATA ls_token    TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lt_parts    TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    CLEAR rv_text.
    lv_curr_idx = iv_from_idx.

    WHILE lv_curr_idx <= iv_to_idx.
      ls_token = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                  iv_index     = lv_curr_idx ).
      IF ls_token-lexeme IS NOT INITIAL.
        APPEND ls_token-lexeme TO lt_parts.
      ENDIF.
      lv_curr_idx += 1.
    ENDWHILE.

    rv_text = concat_lines_of( table = lt_parts
                               sep   = ` ` ).
  ENDMETHOD.

  METHOD build_tab_expr_code.
    DATA ls_first_tok TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_indent    TYPE string.
    DATA lv_expr      TYPE string.

    CLEAR rt_code.
    ls_first_tok = zcl_skylint_ast_util=>get_first_token( is_statement ).
    IF ls_first_tok-position-column > 1.
      lv_indent = repeat( val = ` `
                          occ = ls_first_tok-position-column - 1 ).
    ENDIF.

    lv_expr = |{ is_info-table_name }[ { is_info-cond_text } ]|.

    IF is_info-is_assign = abap_true.
      APPEND |{ lv_indent }ASSIGN { lv_expr } TO { is_info-target_name }.| TO rt_code.
    ELSEIF is_info-is_ref = abap_true.
      APPEND |{ lv_indent }{ is_info-target_name } = REF #( { lv_expr } ).| TO rt_code.
    ELSEIF mv_use_optional = abap_true.
      APPEND |{ lv_indent }{ is_info-target_name } = VALUE #( { lv_expr } OPTIONAL ).| TO rt_code.
    ELSE.
      APPEND |{ lv_indent }{ is_info-target_name } = { lv_expr }.| TO rt_code.
    ENDIF.
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
