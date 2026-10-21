CLASS zcl_skylint_pref_tab_expr DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_tab_expr TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREFTABEXP',
      END OF c_finding_codes.

    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        use_tab_expr TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'USETABEXP',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_TAB_EXPR'.

    DATA mv_use_optional TYPE abap_bool VALUE abap_true.

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

    METHODS build_tab_expr_code
      IMPORTING is_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
                is_info        TYPE ty_read_table_info
      RETURNING VALUE(rt_code) TYPE zcl_skylint_check_base=>ty_code_lines.

ENDCLASS.


CLASS zcl_skylint_pref_tab_expr IMPLEMENTATION.

  METHOD constructor.
    super->constructor(
        VALUE #(
            description       = 'Prefer table expression itab[ ... ] over READ TABLE'
            remote_enablement = abap_true
            finding_codes     = VALUE #( ( code           = c_finding_codes-prefer_tab_expr
                                           severity       = if_ci_atc_check=>finding_severities-warning
                                           text           = 'Prefer table expression itab[ ... ] over READ TABLE'
                                           pseudo_comment = c_pseudo_comment ) )
            quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-use_tab_expr
                                           short_text = 'Replace READ TABLE with table expression' ) )
            attributes        = VALUE #( ( name  = 'USE_OPTIONAL'
                                           kind  = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                           value = REF #( mv_use_optional ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA ls_info     TYPE ty_read_table_info.
    DATA ls_quickfix TYPE zcl_skylint_check_base=>ty_quickfix.
    DATA lt_new_code TYPE zcl_skylint_check_base=>ty_code_lines.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF <ls_statement>-keyword <> 'READ'.
        CONTINUE.
      ENDIF.

      ls_info = parse_read_table( <ls_statement> ).
      IF ls_info-is_valid = abap_false.
        CONTINUE.
      ENDIF.

      lt_new_code = build_tab_expr_code( is_statement = <ls_statement>
                                         is_info      = ls_info ).

      ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-use_tab_expr
                                      iv_statement_from = sy-tabix
                                      it_new_code       = lt_new_code ).

      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-prefer_tab_expr
                        is_quickfix     = ls_quickfix ).
    ENDLOOP.
  ENDMETHOD.

  METHOD parse_read_table.
    DATA lv_idx_table  TYPE i.
    DATA lv_into_pos   TYPE i.
    DATA lv_assign_pos TYPE i.
    DATA lv_ref_pos    TYPE i.
    DATA lv_target_pos TYPE i.
    DATA lv_key_pos    TYPE i.
    DATA lv_index_pos  TYPE i.
    DATA lv_bin_pos    TYPE i.
    DATA lv_no_fld_pos TYPE i.
    DATA lv_tokens_cnt TYPE i.
    DATA ls_tok        TYPE if_ci_atc_source_code_provider=>ty_token.

    CLEAR rs_info.
    lv_tokens_cnt = lines( is_statement-tokens ).
    IF lv_tokens_cnt < 4.
      RETURN.
    ENDIF.

    " Must be READ TABLE
    IF zcl_skylint_ast_util=>matches_token_at( is_statement = is_statement
                                               iv_index     = 2
                                               iv_expected  = `TABLE` ) = abap_false.
      RETURN.
    ENDIF.

    " Ignore BINARY SEARCH (requires sorted table or explicit sort)
    lv_bin_pos = zcl_skylint_ast_util=>find_token_sequence(
                     is_statement = is_statement
                     it_expected  = VALUE #( ( `BINARY` ) ( `SEARCH` ) ) ).
    IF lv_bin_pos > 0.
      RETURN.
    ENDIF.

    " Ignore TRANSPORTING NO FIELDS (covered by prefer-line-exists)
    lv_no_fld_pos = zcl_skylint_ast_util=>find_token_sequence(
                        is_statement = is_statement
                        it_expected  = VALUE #( ( `TRANSPORTING` ) ( `NO` ) ( `FIELDS` ) ) ).
    IF lv_no_fld_pos > 0.
      RETURN.
    ENDIF.

    lv_idx_table = 3.
    ls_tok = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                              iv_index     = lv_idx_table ).
    rs_info-table_name = ls_tok-lexeme.

    lv_into_pos   = zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                      iv_lexeme    = 'INTO' ).
    lv_assign_pos = zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                      iv_lexeme    = 'ASSIGNING' ).
    lv_ref_pos    = zcl_skylint_ast_util=>find_token_sequence(
                        is_statement = is_statement
                        it_expected  = VALUE #( ( `REFERENCE` ) ( `INTO` ) ) ).

    IF lv_into_pos > 0.
      lv_target_pos = lv_into_pos + 1.
    ELSEIF lv_assign_pos > 0.
      rs_info-is_assign = abap_true.
      lv_target_pos = lv_assign_pos + 1.
    ELSEIF lv_ref_pos > 0.
      rs_info-is_ref = abap_true.
      lv_target_pos = lv_ref_pos + 2.
    ELSE.
      RETURN.
    ENDIF.

    ls_tok = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                              iv_index     = lv_target_pos ).
    rs_info-target_name = ls_tok-lexeme.

    lv_index_pos = zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                     iv_lexeme    = 'INDEX' ).
    lv_key_pos   = zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                     iv_lexeme    = 'WITH' ).

    IF lv_index_pos > 0 AND lv_index_pos < lv_tokens_cnt.
      rs_info-is_index  = abap_true.
      rs_info-cond_text = extract_tokens_text( is_statement = is_statement
                                               iv_from_idx  = lv_index_pos + 1
                                               iv_to_idx    = lv_tokens_cnt ).
      rs_info-is_valid  = abap_true.
    ELSEIF lv_key_pos > 0.
      " WITH KEY ... or WITH TABLE KEY ...
      IF zcl_skylint_ast_util=>matches_token_at( is_statement = is_statement
                                                 iv_index     = lv_key_pos + 1
                                                 iv_expected  = `KEY` ) = abap_true.
        rs_info-cond_text = extract_tokens_text( is_statement = is_statement
                                                 iv_from_idx  = lv_key_pos + 2
                                                 iv_to_idx    = lv_tokens_cnt ).
        rs_info-is_valid  = abap_true.
      ELSEIF zcl_skylint_ast_util=>matches_token_at( is_statement = is_statement
                                                     iv_index     = lv_key_pos + 1
                                                     iv_expected  = `TABLE` ) = abap_true
         AND zcl_skylint_ast_util=>matches_token_at( is_statement = is_statement
                                                     iv_index     = lv_key_pos + 2
                                                     iv_expected  = `KEY` ) = abap_true.
        rs_info-cond_text = extract_tokens_text( is_statement = is_statement
                                                 iv_from_idx  = lv_key_pos + 3
                                                 iv_to_idx    = lv_tokens_cnt ).
        rs_info-is_valid  = abap_true.
      ENDIF.
    ENDIF.
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
      " ASSIGN itab[ ... ] TO <fs>.
      APPEND |{ lv_indent }ASSIGN { lv_expr } TO { is_info-target_name }.| TO rt_code.
    ELSEIF is_info-is_ref = abap_true.
      " ref = REF #( itab[ ... ] ).
      APPEND |{ lv_indent }{ is_info-target_name } = REF #( { lv_expr } ).| TO rt_code.
    ELSEIF mv_use_optional = abap_true.
      " target = VALUE #( itab[ ... ] OPTIONAL ).
      APPEND |{ lv_indent }{ is_info-target_name } = VALUE #( { lv_expr } OPTIONAL ).| TO rt_code.
    ELSE.
      APPEND |{ lv_indent }{ is_info-target_name } = { lv_expr }.| TO rt_code.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
