CLASS zcl_skylint_no_many_parens DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        many_parentheses TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_MNY_PAR',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        remove_parentheses TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'NOPARENS',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_MANY_PARENS'.

    METHODS find_matching_close
      IMPORTING is_statement    TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_open         TYPE i
      RETURNING VALUE(rv_close) TYPE i.

    METHODS is_safe_to_remove
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_open       TYPE i
                iv_close      TYPE i
      RETURNING VALUE(rv_yes) TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_no_many_parens IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Remove redundant parentheses'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code           = c_finding_codes-many_parentheses
                                       severity       = if_ci_atc_check=>finding_severities-warning
                                       text           = 'Parentheses wrap a complete expression and can be removed'
                                       pseudo_comment = c_pseudo_comment ) )
                                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-remove_parentheses
                                                                short_text = 'Remove redundant parentheses' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_index    TYPE i.
    DATA lv_count    TYPE i.
    DATA lv_open     TYPE i.
    DATA lv_close    TYPE i.
    DATA ls_open     TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_report   TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_line     TYPE string.
    DATA ls_quickfix TYPE zcl_skylint_check_base=>ty_quickfix.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      IF     <ls_statement>-keyword <> 'IF'
         AND <ls_statement>-keyword <> 'ELSEIF'
         AND <ls_statement>-keyword <> 'WHILE'
         AND <ls_statement>-keyword <> 'CHECK'
         AND <ls_statement>-keyword <> 'COMPUTE'.
        CONTINUE.
      ENDIF.

      lv_count = zcl_skylint_ast_util=>token_count( <ls_statement> ).
      lv_index = 1.
      WHILE lv_index <= lv_count.
        ls_open = zcl_skylint_ast_util=>get_token( is_statement = <ls_statement>
                                                   iv_index     = lv_index ).
        lv_open = lv_index.
        IF ls_open-lexeme <> '('.
          lv_index += 1.
          CONTINUE.
        ENDIF.

        lv_close = find_matching_close( is_statement = <ls_statement>
                                        iv_open      = lv_open ).
        IF lv_close = 0.
          lv_index += 1.
          CONTINUE.
        ENDIF.

        IF is_safe_to_remove( is_statement = <ls_statement>
                              iv_open      = lv_open
                              iv_close     = lv_close ) = abap_true.
          lv_line = zcl_skylint_ast_util=>flatten_statement( is_statement = <ls_statement>
                                                             it_deletions = VALUE #( ( lv_open ) ( lv_close ) )
                                                             iv_suffix    = `.` ).
          ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-remove_parentheses
                                          iv_statement_from = sy-tabix
                                          it_new_code       = VALUE #( ( lv_line ) ) ).

          ls_report = zcl_skylint_ast_util=>get_token( is_statement = <ls_statement>
                                                       iv_index     = lv_open ).
          report_token( is_token        = ls_report
                        is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-many_parentheses
                        is_quickfix     = ls_quickfix ).
        ENDIF.

        lv_index = lv_close + 1.
      ENDWHILE.
    ENDLOOP.
  ENDMETHOD.

  METHOD find_matching_close.
    DATA lv_count TYPE i.
    DATA lv_idx   TYPE i.
    DATA lv_depth TYPE i.
    DATA ls_tok   TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_close = 0.
    lv_count = zcl_skylint_ast_util=>token_count( is_statement ).
    lv_idx = iv_open + 1.
    lv_depth = 0.

    WHILE lv_idx <= lv_count.
      ls_tok = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                iv_index     = lv_idx ).
      lv_depth += zcl_skylint_ast_util=>token_paren_delta( ls_tok ).
      IF lv_depth = -1 AND ls_tok-lexeme = ')'.
        rv_close = lv_idx.
        RETURN.
      ENDIF.
      IF lv_depth < -1.
        RETURN.
      ENDIF.
      lv_idx += 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD is_safe_to_remove.
    DATA lv_count    TYPE i.
    DATA lv_idx      TYPE i.
    DATA lv_depth    TYPE i.
    DATA lv_has_cond TYPE abap_bool.
    DATA lv_has_or   TYPE abap_bool.
    DATA lv_has_and  TYPE abap_bool.
    DATA ls_tok      TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_prev     TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_next     TYPE if_ci_atc_source_code_provider=>ty_token.

    rv_yes = abap_false.
    lv_count = zcl_skylint_ast_util=>token_count( is_statement ).

    IF iv_open > 1.
      ls_prev = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                 iv_index     = iv_open - 1 ).
      IF zcl_skylint_ast_util=>token_is_keyword( is_token  = ls_prev
                                                 iv_lexeme = 'NOT' ) = abap_true.
        RETURN.
      ENDIF.
    ENDIF.

    lv_idx = iv_open + 1.
    lv_depth = 0.
    WHILE lv_idx < iv_close.
      ls_tok = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                iv_index     = lv_idx ).
      IF lv_depth = 0 AND zcl_skylint_ast_util=>token_is_keyword( ls_tok ) = abap_true.
        IF    zcl_skylint_ast_util=>is_comparison_operator( ls_tok-lexeme ) = abap_true
           OR ls_tok-lexeme = 'IS'
           OR ls_tok-lexeme = 'IN'
           OR ls_tok-lexeme = 'BETWEEN'.
          lv_has_cond = abap_true.
        ELSEIF ls_tok-lexeme = 'OR' OR ls_tok-lexeme = 'EQUIV'.
          lv_has_or = abap_true.
        ELSEIF ls_tok-lexeme = 'AND'.
          lv_has_and = abap_true.
        ENDIF.
      ENDIF.
      lv_depth += zcl_skylint_ast_util=>token_paren_delta( ls_tok ).
      IF lv_depth < 0.
        lv_depth = 0.
      ENDIF.
      lv_idx += 1.
    ENDWHILE.

    IF lv_has_cond = abap_false.
      RETURN.
    ENDIF.

    IF iv_open = 2 AND iv_close = lv_count.
      rv_yes = abap_true.
      RETURN.
    ENDIF.

    IF lv_has_or = abap_true AND iv_open > 1.
      ls_prev = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                 iv_index     = iv_open - 1 ).
      IF zcl_skylint_ast_util=>token_is_keyword( is_token  = ls_prev
                                                 iv_lexeme = 'AND' ) = abap_true.
        RETURN.
      ENDIF.
    ENDIF.

    IF lv_has_or = abap_true AND iv_close < lv_count.
      ls_next = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                 iv_index     = iv_close + 1 ).
      IF zcl_skylint_ast_util=>token_is_keyword( is_token  = ls_next
                                                 iv_lexeme = 'AND' ) = abap_true.
        RETURN.
      ENDIF.
    ENDIF.

    IF lv_has_and = abap_true OR lv_has_or = abap_true.
      RETURN.
    ENDIF.

    rv_yes = abap_true.
  ENDMETHOD.
ENDCLASS.
