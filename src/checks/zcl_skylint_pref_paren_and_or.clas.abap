CLASS zcl_skylint_pref_paren_and_or DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        parenthesize_and_or TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_PAREN',
      END OF c_finding_codes.

    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        parenthesize TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'ADD_PAREN',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_PAREN_AND_OR'.

    TYPES:
      BEGIN OF ty_depth_state,
        depth   TYPE i,
        has_and TYPE abap_bool,
        has_or  TYPE abap_bool,
        between TYPE abap_bool,
      END OF ty_depth_state,
      ty_depth_states TYPE STANDARD TABLE OF ty_depth_state WITH EMPTY KEY.

    METHODS is_conditional_statement
      IMPORTING iv_keyword    TYPE string
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    METHODS has_mixed_and_or
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    METHODS build_parenthesized_fix
      IMPORTING is_statement       TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_stmt_idx        TYPE i
      RETURNING VALUE(rs_quickfix) TYPE ty_quickfix.

ENDCLASS.


CLASS zcl_skylint_pref_paren_and_or IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Parenthesize Combinations of AND and OR'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-parenthesize_and_or
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Parenthesize combinations of AND and OR to eliminate ambiguity'
                       pseudo_comment = c_pseudo_comment ) )
                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-parenthesize
                                                short_text = 'Parenthesize AND groups in mixed AND/OR' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_stmt_idx TYPE i.
    DATA ls_quickfix TYPE ty_quickfix.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_stmt_idx = sy-tabix.
      IF is_conditional_statement( <ls_statement>-keyword ) = abap_false.
        CONTINUE.
      ENDIF.

      IF has_mixed_and_or( <ls_statement> ) = abap_true.
        ls_quickfix = build_parenthesized_fix( is_statement = <ls_statement>
                                               iv_stmt_idx  = lv_stmt_idx ).
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-parenthesize_and_or
                          is_quickfix     = ls_quickfix ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_conditional_statement.
    rv_yes = abap_false.
    IF    iv_keyword = 'IF'
       OR iv_keyword = 'ELSEIF'
       OR iv_keyword = 'CHECK'
       OR iv_keyword = 'WHILE'.
      rv_yes = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD has_mixed_and_or.
    DATA lv_tok_cnt TYPE i.
    DATA lv_idx     TYPE i.
    DATA lv_depth   TYPE i.
    DATA lv_delta   TYPE i.
    DATA lt_states  TYPE ty_depth_states.
    DATA ls_tok     TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_state> TYPE ty_depth_state.

    rv_yes = abap_false.
    lv_tok_cnt = zcl_skylint_ast_util=>token_count( is_statement ).
    lv_depth = 0.
    lv_idx = 1.

    WHILE lv_idx <= lv_tok_cnt.
      ls_tok = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                iv_index     = lv_idx ).
      lv_delta = zcl_skylint_ast_util=>token_paren_delta( ls_tok ).
      IF lv_delta > 0.
        lv_depth += lv_delta.
      ENDIF.

      ASSIGN lt_states[ depth = lv_depth ] TO <ls_state>.
      IF sy-subrc <> 0.
        APPEND VALUE #( depth = lv_depth ) TO lt_states ASSIGNING <ls_state>.
      ENDIF.

      IF ls_tok-references IS INITIAL.
        CASE ls_tok-lexeme.
          WHEN 'BETWEEN'.
            <ls_state>-between = abap_true.

          WHEN 'AND'.
            IF <ls_state>-between = abap_true.
              <ls_state>-between = abap_false.
            ELSE.
              <ls_state>-has_and = abap_true.
              IF <ls_state>-has_or = abap_true.
                rv_yes = abap_true.
                RETURN.
              ENDIF.
            ENDIF.

          WHEN 'OR' OR 'EQUIV'.
            <ls_state>-has_or = abap_true.
            IF <ls_state>-has_and = abap_true.
              rv_yes = abap_true.
              RETURN.
            ENDIF.
        ENDCASE.
      ENDIF.

      IF lv_delta < 0.
        lv_depth += lv_delta.
        IF lv_depth < 0.
          lv_depth = 0.
        ENDIF.
      ENDIF.
      lv_idx += 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD build_parenthesized_fix.
    TYPES:
      BEGIN OF ty_clause,
        from_idx TYPE i,
        to_idx   TYPE i,
        has_and  TYPE abap_bool,
      END OF ty_clause.

    DATA lv_tok_cnt        TYPE i.
    DATA lv_idx            TYPE i.
    DATA lv_depth          TYPE i.
    DATA lv_delta          TYPE i.
    DATA lv_clause_from    TYPE i.
    DATA lv_clause_to      TYPE i.
    DATA lv_clause_has_and TYPE abap_bool.
    DATA lv_between        TYPE abap_bool.
    DATA lv_indent         TYPE string.
    DATA lv_line           TYPE string.
    DATA lt_clauses        TYPE STANDARD TABLE OF ty_clause WITH EMPTY KEY.
    DATA ls_tok            TYPE if_ci_atc_source_code_provider=>ty_token.
    FIELD-SYMBOLS <ls_cl> TYPE ty_clause.

    CLEAR rs_quickfix.
    lv_tok_cnt = zcl_skylint_ast_util=>token_count( is_statement ).
    IF lv_tok_cnt < 3.
      RETURN.
    ENDIF.

    lv_clause_from = 2.
    lv_depth = 0.
    lv_idx = 2.

    WHILE lv_idx <= lv_tok_cnt.
      ls_tok = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                iv_index     = lv_idx ).
      lv_delta = zcl_skylint_ast_util=>token_paren_delta( ls_tok ).
      IF lv_delta > 0.
        lv_depth += lv_delta.
      ENDIF.

      IF lv_depth = 0 AND ls_tok-references IS INITIAL.
        CASE ls_tok-lexeme.
          WHEN 'BETWEEN'.
            lv_between = abap_true.
          WHEN 'AND'.
            IF lv_between = abap_true.
              lv_between = abap_false.
            ELSE.
              lv_clause_has_and = abap_true.
            ENDIF.
          WHEN 'OR' OR 'EQUIV'.
            lv_clause_to = lv_idx - 1.
            APPEND VALUE #( from_idx = lv_clause_from
                            to_idx   = lv_clause_to
                            has_and  = lv_clause_has_and ) TO lt_clauses.
            lv_clause_from = lv_idx + 1.
            lv_clause_has_and = abap_false.
        ENDCASE.
      ENDIF.

      IF lv_delta < 0.
        lv_depth += lv_delta.
        IF lv_depth < 0.
          lv_depth = 0.
        ENDIF.
      ENDIF.
      lv_idx += 1.
    ENDWHILE.

    IF lv_clause_from <= lv_tok_cnt.
      APPEND VALUE #( from_idx = lv_clause_from
                      to_idx   = lv_tok_cnt
                      has_and  = lv_clause_has_and ) TO lt_clauses.
    ENDIF.

    IF is_statement-position-column > 1.
      lv_indent = repeat( val = ` `
                          occ = is_statement-position-column - 1 ).
    ENDIF.

    lv_line = |{ lv_indent }{ is_statement-keyword }|.

    LOOP AT lt_clauses ASSIGNING <ls_cl>.
      IF sy-tabix > 1.
        ls_tok = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                  iv_index     = <ls_cl>-from_idx - 1 ).
        lv_line = |{ lv_line } { ls_tok-lexeme }|.
      ENDIF.

      IF <ls_cl>-has_and = abap_true.
        lv_line = |{ lv_line } (|.
      ENDIF.

      lv_idx = <ls_cl>-from_idx.
      WHILE lv_idx <= <ls_cl>-to_idx.
        ls_tok = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                  iv_index     = lv_idx ).
        lv_line = |{ lv_line } { ls_tok-lexeme }|.
        lv_idx += 1.
      ENDWHILE.

      IF <ls_cl>-has_and = abap_true.
        lv_line = |{ lv_line } )|.
      ENDIF.
    ENDLOOP.

    lv_line = |{ lv_line }.|.
    rs_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-parenthesize
                                    iv_statement_from = iv_stmt_idx
                                    it_new_code       = VALUE #( ( lv_line ) ) ).
  ENDMETHOD.
ENDCLASS.
