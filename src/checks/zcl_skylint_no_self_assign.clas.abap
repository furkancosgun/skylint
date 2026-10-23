CLASS zcl_skylint_no_self_assign DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        identical_move TYPE if_ci_atc_check=>ty_finding_code VALUE 'IDENTMOVE',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        delete_self TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'DELIDENT',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'SELF_ASSIGN'.

    METHODS get_written_symbol
      IMPORTING is_token         TYPE if_ci_atc_source_code_provider=>ty_token
      RETURNING VALUE(rv_symbol) TYPE string.

    METHODS get_read_symbol
      IMPORTING is_token         TYPE if_ci_atc_source_code_provider=>ty_token
      RETURNING VALUE(rv_symbol) TYPE string.

    METHODS is_identical_assignment
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

    METHODS is_identical_move
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_res) TYPE abap_bool.

    METHODS find_move_to
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_idx) TYPE i.

ENDCLASS.


CLASS zcl_skylint_no_self_assign IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'skylint: Detect Identical Self Assignments'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-identical_move
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Identical assignment has no effect; remove redundant statement'
                                       pseudo_comment = c_pseudo_comment ) )
                                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-delete_self
                                                                short_text = 'Delete self-assignment' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx  TYPE i.
    DATA lv_identical TYPE abap_bool.
    DATA ls_quickfix  TYPE zcl_skylint_check_base=>ty_quickfix.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'COMPUTE'.
          lv_identical = is_identical_assignment( <ls_statement> ).
        WHEN 'MOVE'.
          lv_identical = is_identical_move( <ls_statement> ).
        WHEN OTHERS.
          CONTINUE.
      ENDCASE.

      IF lv_identical = abap_false.
        CONTINUE.
      ENDIF.

      lv_stmt_idx = sy-tabix.
      ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-delete_self
                                      iv_statement_from = lv_stmt_idx
                                      it_new_code       = VALUE #( ) ).
      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-identical_move
                        is_quickfix     = ls_quickfix ).
    ENDLOOP.
  ENDMETHOD.

  METHOD get_written_symbol.
    DATA ls_ref TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    ls_ref = zcl_skylint_ast_util=>get_reference(
                 is_token = is_token
                 iv_kind  = if_ci_atc_source_code_provider=>compiler_reference_kinds-data ).
    IF ls_ref-full_name IS NOT INITIAL AND zcl_skylint_ast_util=>is_write_usage( ls_ref ) = abap_true.
      rv_symbol = ls_ref-full_name.
    ENDIF.
  ENDMETHOD.

  METHOD get_read_symbol.
    DATA ls_ref TYPE if_ci_atc_source_code_provider=>ty_compiler_reference.

    ls_ref = zcl_skylint_ast_util=>get_reference(
                 is_token = is_token
                 iv_kind  = if_ci_atc_source_code_provider=>compiler_reference_kinds-data ).
    IF ls_ref-full_name IS NOT INITIAL AND zcl_skylint_ast_util=>is_read_usage( ls_ref ) = abap_true.
      rv_symbol = ls_ref-full_name.
    ENDIF.
  ENDMETHOD.

  METHOD is_identical_assignment.
    DATA lv_eq_idx     TYPE i.
    DATA ls_tok_eq     TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_tok_left   TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_tok_right  TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_tok_after  TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_lhs_symbol TYPE string.
    DATA lv_rhs_symbol TYPE string.

    rv_res = abap_false.

    lv_eq_idx = zcl_skylint_ast_util=>find_token( is_statement = is_statement
                                                  iv_lexeme    = '=' ).
    IF lv_eq_idx <= 1 OR lv_eq_idx >= lines( is_statement-tokens ).
      RETURN.
    ENDIF.

    ls_tok_eq = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                 iv_index     = lv_eq_idx ).
    IF ls_tok_eq-references IS NOT INITIAL.
      RETURN.
    ENDIF.

    IF lines( is_statement-tokens ) > lv_eq_idx + 1.
      ls_tok_after = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                      iv_index     = lv_eq_idx + 2 ).
      IF ls_tok_after-lexeme IS NOT INITIAL AND NOT ( ls_tok_after-lexeme CP '##*' OR ls_tok_after-lexeme = '.' ).
        RETURN.
      ENDIF.
    ENDIF.

    ls_tok_left  = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                    iv_index     = lv_eq_idx - 1 ).
    ls_tok_right = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                    iv_index     = lv_eq_idx + 1 ).

    lv_lhs_symbol = get_written_symbol( ls_tok_left ).
    lv_rhs_symbol = get_read_symbol( ls_tok_right ).

    IF     lv_lhs_symbol IS NOT INITIAL
       AND lv_rhs_symbol IS NOT INITIAL
       AND lv_lhs_symbol  = lv_rhs_symbol.
      rv_res = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD is_identical_move.
    DATA lv_tok_cnt    TYPE i.
    DATA lv_to_idx     TYPE i.
    DATA lv_src_idx    TYPE i.
    DATA lv_tgt_idx    TYPE i.
    DATA ls_token      TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_tok_src    TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_tok_tgt    TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_src_symbol TYPE string.
    DATA lv_tgt_symbol TYPE string.

    rv_res = abap_false.
    lv_tok_cnt = zcl_skylint_ast_util=>token_count( is_statement ).
    lv_to_idx = find_move_to( is_statement ).
    IF lv_to_idx < 3.
      RETURN.
    ENDIF.

    lv_src_idx = 2.
    ls_token = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                iv_index     = lv_src_idx ).
    IF to_upper( ls_token-lexeme ) = 'EXACT'.
      lv_src_idx += 1.
    ENDIF.

    IF lv_to_idx <> lv_src_idx + 1.
      RETURN.
    ENDIF.

    lv_tgt_idx = lv_to_idx + 1.
    IF lv_tgt_idx <> lv_tok_cnt.
      RETURN.
    ENDIF.

    ls_tok_src = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                  iv_index     = lv_src_idx ).
    ls_tok_tgt = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                  iv_index     = lv_tgt_idx ).

    lv_src_symbol = get_read_symbol( ls_tok_src ).
    lv_tgt_symbol = get_written_symbol( ls_tok_tgt ).

    IF     lv_src_symbol IS NOT INITIAL
       AND lv_src_symbol  = lv_tgt_symbol.
      rv_res = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD find_move_to.
    DATA lv_idx   TYPE i.
    DATA lv_cnt   TYPE i.
    DATA lv_lex   TYPE string.
    DATA ls_token TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_idx = 0.
    lv_cnt = zcl_skylint_ast_util=>token_count( is_statement ).
    lv_idx = 2.

    WHILE lv_idx <= lv_cnt.
      ls_token = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                  iv_index     = lv_idx ).
      lv_lex = to_upper( ls_token-lexeme ).
      IF ls_token-references IS INITIAL AND ( lv_lex = 'TO' OR lv_lex = '?TO' ).
        rv_idx = lv_idx.
        RETURN.
      ENDIF.
      lv_idx += 1.
    ENDWHILE.
  ENDMETHOD.
ENDCLASS.
