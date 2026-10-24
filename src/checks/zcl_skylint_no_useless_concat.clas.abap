CLASS zcl_skylint_no_useless_concat DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        useless_concat TYPE if_ci_atc_check=>ty_finding_code VALUE 'USELESSCAT',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        fold_literals TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'FOLDLIT',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_USELESS_CONCAT'.

    METHODS concat_chain
      IMPORTING is_statement    TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_operator_idx TYPE i
      EXPORTING ev_start        TYPE i
                ev_end          TYPE i.

    METHODS chain_is_literal
      IMPORTING is_statement    TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_start        TYPE i
                iv_end          TYPE i
      EXPORTING ev_ok           TYPE abap_bool
                ev_count        TYPE i
                ev_all_foldable TYPE abap_bool.

    METHODS is_operand_literal
      IMPORTING is_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_pos         TYPE i
      EXPORTING ev_next_pos    TYPE i
                ev_is_literal  TYPE abap_bool
                ev_is_foldable TYPE abap_bool.

    METHODS is_concat_operator
      IMPORTING is_token      TYPE if_ci_atc_source_code_provider=>ty_token
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    METHODS is_string_literal
      IMPORTING is_token      TYPE if_ci_atc_source_code_provider=>ty_token
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    METHODS build_fold_quickfix
      IMPORTING is_statement       TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_statement_idx   TYPE i
                iv_start           TYPE i
                iv_end             TYPE i
      RETURNING VALUE(rs_quickfix) TYPE zcl_skylint_check_base=>ty_quickfix.

ENDCLASS.


CLASS zcl_skylint_no_useless_concat IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Avoid concatenating string literals'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-useless_concat
                                       severity       = if_ci_atc_check=>finding_severities-note
                                       text           = 'Fold literal string concatenation into one literal'
                                       pseudo_comment = c_pseudo_comment ) )
                                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-fold_literals
                                                                short_text = 'Fold literals' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_idx          TYPE i.
    DATA lv_stmt_idx     TYPE i.
    DATA lv_start        TYPE i.
    DATA lv_end          TYPE i.
    DATA lv_count        TYPE i.
    DATA lv_all_lit      TYPE abap_bool.
    DATA lv_all_foldable TYPE abap_bool.
    DATA ls_operator     TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_quickfix     TYPE zcl_skylint_check_base=>ty_quickfix.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_stmt_idx = sy-tabix.
      lv_idx = 1.
      WHILE lv_idx <= lines( <ls_statement>-tokens ).
        ls_operator = zcl_skylint_ast_util=>get_token( is_statement = <ls_statement>
                                                       iv_index     = lv_idx ).
        IF is_concat_operator( ls_operator ) = abap_false.
          lv_idx += 1.
          CONTINUE.
        ENDIF.

        concat_chain( EXPORTING is_statement    = <ls_statement>
                                iv_operator_idx = lv_idx
                      IMPORTING ev_start        = lv_start
                                ev_end          = lv_end ).

        chain_is_literal( EXPORTING is_statement    = <ls_statement>
                                    iv_start        = lv_start
                                    iv_end          = lv_end
                          IMPORTING ev_ok           = lv_all_lit
                                    ev_count        = lv_count
                                    ev_all_foldable = lv_all_foldable ).

        IF lv_all_lit = abap_true AND lv_count >= 2.
          CLEAR ls_quickfix.
          IF lv_all_foldable = abap_true.
            ls_quickfix = build_fold_quickfix( is_statement     = <ls_statement>
                                               iv_statement_idx = lv_stmt_idx
                                               iv_start         = lv_start
                                               iv_end           = lv_end ).
          ENDIF.

          report_token( is_token        = ls_operator
                        is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-useless_concat
                        is_quickfix     = ls_quickfix ).
          lv_idx = lv_end + 1.
          CONTINUE.
        ENDIF.

        lv_idx += 1.
      ENDWHILE.
    ENDLOOP.
  ENDMETHOD.

  METHOD concat_chain.
    DATA lv_tok_count TYPE i.
    DATA lv_curr_op   TYPE i.
    DATA lv_left_st   TYPE i.
    DATA lv_right_end TYPE i.
    DATA ls_tok_prev  TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_tok_next  TYPE if_ci_atc_source_code_provider=>ty_token.

    ev_start = 0.
    ev_end = 0.
    lv_tok_count = lines( is_statement-tokens ).

    IF is_concat_operator( zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                            iv_index     = iv_operator_idx ) ) = abap_false.
      RETURN.
    ENDIF.

    " Expand left
    lv_curr_op = iv_operator_idx.
    DO.
      IF lv_curr_op <= 1.
        EXIT.
      ENDIF.
      ls_tok_prev = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                    iv_index     = lv_curr_op - 1 ).
      IF ls_tok_prev-lexeme = '|'.
        IF lv_curr_op >= 4 AND zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                                       iv_index     = lv_curr_op - 3 ) = '|'.
          lv_left_st = lv_curr_op - 3.
        ELSEIF lv_curr_op >= 3 AND zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                                           iv_index     = lv_curr_op - 2 ) = '|'.
          lv_left_st = lv_curr_op - 2.
        ELSE.
          lv_left_st = lv_curr_op - 1.
        ENDIF.
      ELSE.
        lv_left_st = lv_curr_op - 1.
      ENDIF.

      ev_start = lv_left_st.
      IF     lv_left_st >= 2
         AND is_concat_operator( zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                                  iv_index     = lv_left_st - 1 ) ) = abap_true.
        lv_curr_op = lv_left_st - 1.
        CONTINUE.
      ENDIF.
      EXIT.
    ENDDO.

    " Expand right
    lv_curr_op = iv_operator_idx.
    DO.
      IF lv_curr_op >= lv_tok_count.
        EXIT.
      ENDIF.
      ls_tok_next = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                    iv_index     = lv_curr_op + 1 ).
      IF ls_tok_next-lexeme = '|'.
        IF lv_curr_op + 3 <= lv_tok_count AND zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                                                       iv_index     = lv_curr_op + 3 ) = '|'.
          lv_right_end = lv_curr_op + 3.
        ELSEIF lv_curr_op + 2 <= lv_tok_count AND zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                                                           iv_index     = lv_curr_op + 2 ) = '|'.
          lv_right_end = lv_curr_op + 2.
        ELSE.
          lv_right_end = lv_curr_op + 1.
        ENDIF.
      ELSE.
        lv_right_end = lv_curr_op + 1.
      ENDIF.

      ev_end = lv_right_end.
      IF     lv_right_end + 1 <= lv_tok_count
         AND is_concat_operator( zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                                  iv_index     = lv_right_end + 1 ) ) = abap_true.
        lv_curr_op = lv_right_end + 1.
        CONTINUE.
      ENDIF.
      EXIT.
    ENDDO.
  ENDMETHOD.

  METHOD is_operand_literal.
    DATA ls_tok TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_mid TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_end TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_cnt TYPE i.

    ev_is_literal = abap_false.
    ev_is_foldable = abap_false.
    ev_next_pos = iv_pos + 1.
    lv_cnt = lines( is_statement-tokens ).
    IF iv_pos < 1 OR iv_pos > lv_cnt.
      RETURN.
    ENDIF.

    ls_tok = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                              iv_index     = iv_pos ).

    IF is_string_literal( ls_tok ) = abap_true.
      ev_is_literal = abap_true.
      IF ls_tok-lexeme(1) = `'` OR ls_tok-lexeme(1) = '`'.
        ev_is_foldable = abap_true.
      ENDIF.
      RETURN.
    ENDIF.

    " Multi-token template: | text | or | |
    IF ls_tok-lexeme = '|'.
      IF iv_pos + 2 <= lv_cnt.
        ls_mid = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                  iv_index     = iv_pos + 1 ).
        ls_end = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                  iv_index     = iv_pos + 2 ).
        IF ls_end-lexeme = '|' AND ls_mid-lexeme NS '{' AND ls_mid-lexeme NS '}'.
          ev_is_literal = abap_true.
          ev_is_foldable = abap_false.
          ev_next_pos = iv_pos + 3.
          RETURN.
        ENDIF.
      ENDIF.

      IF iv_pos + 1 <= lv_cnt.
        ls_end = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                  iv_index     = iv_pos + 1 ).
        IF ls_end-lexeme = '|'.
          ev_is_literal = abap_true.
          ev_is_foldable = abap_false.
          ev_next_pos = iv_pos + 2.
          RETURN.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD chain_is_literal.
    DATA lv_pos      TYPE i.
    DATA lv_next_pos TYPE i.
    DATA lv_is_lit   TYPE abap_bool.
    DATA lv_foldable TYPE abap_bool.
    DATA ls_tok      TYPE if_ci_atc_source_code_provider=>ty_token.

    ev_ok = abap_true.
    ev_count = 0.
    ev_all_foldable = abap_true.
    lv_pos = iv_start.

    WHILE lv_pos <= iv_end.
      is_operand_literal( EXPORTING is_statement   = is_statement
                                    iv_pos         = lv_pos
                          IMPORTING ev_next_pos    = lv_next_pos
                                    ev_is_literal  = lv_is_lit
                                    ev_is_foldable = lv_foldable ).
      IF lv_is_lit = abap_false.
        ev_ok = abap_false.
        ev_count = 0.
        RETURN.
      ENDIF.

      ev_count += 1.
      IF lv_foldable = abap_false.
        ev_all_foldable = abap_false.
      ENDIF.

      IF lv_next_pos <= iv_end.
        ls_tok = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                  iv_index     = lv_next_pos ).
        IF is_concat_operator( ls_tok ) = abap_false.
          ev_ok = abap_false.
          ev_count = 0.
          RETURN.
        ENDIF.
        lv_pos = lv_next_pos + 1.
      ELSE.
        lv_pos = lv_next_pos.
      ENDIF.
    ENDWHILE.
  ENDMETHOD.

  METHOD is_concat_operator.
    rv_yes = zcl_skylint_ast_util=>token_is_keyword( is_token  = is_token
                                                     iv_lexeme = '&&' ).
  ENDMETHOD.

  METHOD is_string_literal.
    DATA lv_len   TYPE i.
    DATA lv_first TYPE string.
    DATA lv_last  TYPE string.

    rv_yes = abap_false.
    lv_len = strlen( is_token-lexeme ).
    IF lv_len < 2.
      RETURN.
    ENDIF.

    lv_first = substring( val = is_token-lexeme
                          off = 0
                          len = 1 ).
    lv_last = substring( val = is_token-lexeme
                         off = lv_len - 1
                         len = 1 ).

    IF lv_first = `'` AND lv_last = `'`.
      rv_yes = abap_true.
    ELSEIF lv_first = '`' AND lv_last = '`'.
      rv_yes = abap_true.
    ELSEIF lv_first = '|' AND lv_last = '|' AND is_token-lexeme NS '{'.
      rv_yes = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD build_fold_quickfix.
    DATA lv_pos       TYPE i.
    DATA lv_lexeme    TYPE string.
    DATA lv_quote     TYPE string.
    DATA lv_inner     TYPE string.
    DATA lv_content   TYPE string.
    DATA lv_delimiter TYPE string.
    DATA lv_literal   TYPE string.
    DATA lv_line      TYPE string.
    DATA lv_all_char  TYPE abap_bool VALUE abap_true.
    DATA lt_overrides TYPE zcl_skylint_ast_util=>ty_token_overrides.
    DATA lt_deletions TYPE zcl_skylint_ast_util=>ty_token_deletions.

    lv_pos = iv_start.
    WHILE lv_pos <= iv_end.
      lv_lexeme = zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                          iv_index     = lv_pos ).
      IF is_string_literal( zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                             iv_index     = lv_pos ) ) = abap_false.
        RETURN.
      ENDIF.

      lv_quote = substring( val = lv_lexeme
                            off = 0
                            len = 1 ).
      IF lv_quote = '|'.
        RETURN.
      ENDIF.
      IF lv_quote <> `'`.
        lv_all_char = abap_false.
      ENDIF.

      IF strlen( lv_lexeme ) > 2.
        lv_inner = substring( val = lv_lexeme
                              off = 1
                              len = strlen( lv_lexeme ) - 2 ).
        lv_content = |{ lv_content }{ lv_inner }|.
      ENDIF.
      lv_pos += 2.
    ENDWHILE.

    IF lv_all_char = abap_true AND strlen( lv_content ) <= 250.
      lv_delimiter = `'`.
    ELSE.
      lv_delimiter = '`'.
    ENDIF.
    lv_literal = |{ lv_delimiter }{ lv_content }{ lv_delimiter }|.

    lt_overrides = VALUE #( ( index  = iv_start
                              lexeme = lv_literal ) ).
    lv_pos = iv_start + 1.
    WHILE lv_pos <= iv_end.
      APPEND lv_pos TO lt_deletions.
      lv_pos += 1.
    ENDWHILE.

    lv_line = zcl_skylint_ast_util=>flatten_statement( is_statement = is_statement
                                                       it_overrides = lt_overrides
                                                       it_deletions = lt_deletions ).
    rs_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-fold_literals
                                    iv_statement_from = iv_statement_idx
                                    it_new_code       = VALUE #( ( |{ lv_line }.| ) ) ).
  ENDMETHOD.
ENDCLASS.
