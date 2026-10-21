CLASS zcl_skylint_pref_switch DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_switch TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREFSWITCH',
      END OF c_finding_codes.

    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        use_switch TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'USESWITCH',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_SWITCH'.

    DATA mv_require_others TYPE abap_bool VALUE abap_false.

    TYPES:
      BEGIN OF ty_when_branch,
        when_idx   TYPE i,
        is_others  TYPE abap_bool,
        cond_text  TYPE string,
        target_var TYPE string,
        expr_text  TYPE string,
      END OF ty_when_branch,
      ty_when_branches TYPE STANDARD TABLE OF ty_when_branch WITH EMPTY KEY.

    METHODS parse_assignment
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
      EXPORTING ev_target    TYPE string
                ev_expr      TYPE string
                ev_is_assign TYPE abap_bool.

    METHODS extract_tokens_text
      IMPORTING is_statement   TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_from_idx    TYPE i
                iv_to_idx      TYPE i
      RETURNING VALUE(rv_text) TYPE string.

    METHODS is_when_others
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_is) TYPE abap_bool.

    METHODS build_switch_code
      IMPORTING is_case_stmt   TYPE if_ci_atc_source_code_provider=>ty_statement
                it_branches    TYPE ty_when_branches
                iv_target      TYPE string
      RETURNING VALUE(rt_code) TYPE zcl_skylint_check_base=>ty_code_lines.

    METHODS scan_case_branches
      IMPORTING iv_case_idx    TYPE i
                it_statements  TYPE if_ci_atc_source_code_provider=>ty_statements
                iv_total       TYPE i
      EXPORTING et_branches    TYPE ty_when_branches
                ev_target      TYPE string
                ev_endcase_idx TYPE i
                ev_valid       TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_pref_switch IMPLEMENTATION.

  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Prefer SWITCH #( ) expression over CASE statement'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #( ( code           = c_finding_codes-prefer_switch
                                                severity       = if_ci_atc_check=>finding_severities-warning
                                                text           = 'Prefer SWITCH #( ) constructor expression over CASE'
                                                pseudo_comment = c_pseudo_comment ) )
                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-use_switch
                                                short_text = 'Replace CASE with SWITCH #( )' ) )
                 attributes        = VALUE #( ( name  = 'REQUIRE_OTHERS'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                                value = REF #( mv_require_others ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_idx         TYPE i.
    DATA lv_total       TYPE i.
    DATA lt_branches    TYPE ty_when_branches.
    DATA lv_target      TYPE string.
    DATA lv_endcase_idx TYPE i.
    DATA lv_valid       TYPE abap_bool.
    DATA ls_quickfix    TYPE zcl_skylint_check_base=>ty_quickfix.
    DATA lt_new_code    TYPE zcl_skylint_check_base=>ty_code_lines.
    FIELD-SYMBOLS <ls_case> TYPE if_ci_atc_source_code_provider=>ty_statement.

    lv_total = zcl_skylint_ast_util=>statement_count( is_procedure-statements ).

    LOOP AT is_procedure-statements ASSIGNING <ls_case>.
      IF <ls_case>-keyword <> 'CASE'.
        CONTINUE.
      ENDIF.

      IF lines( <ls_case>-tokens ) < 2.
        CONTINUE.
      ENDIF.

      lv_idx = sy-tabix.

      scan_case_branches( EXPORTING iv_case_idx    = lv_idx
                                    it_statements  = is_procedure-statements
                                    iv_total       = lv_total
                          IMPORTING et_branches    = lt_branches
                                    ev_target      = lv_target
                                    ev_endcase_idx = lv_endcase_idx
                                    ev_valid       = lv_valid ).

      IF lv_valid = abap_false OR lv_endcase_idx = 0 OR lines( lt_branches ) = 0.
        CONTINUE.
      ENDIF.

      lt_new_code = build_switch_code( is_case_stmt = <ls_case>
                                       it_branches  = lt_branches
                                       iv_target    = lv_target ).

      ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-use_switch
                                      iv_statement_from = lv_idx
                                      iv_statement_to   = lv_endcase_idx
                                      it_new_code       = lt_new_code ).

      report_statement( is_statement    = <ls_case>
                        iv_finding_code = c_finding_codes-prefer_switch
                        is_quickfix     = ls_quickfix ).
    ENDLOOP.
  ENDMETHOD.

  METHOD scan_case_branches.
    DATA lv_curr        TYPE i.
    DATA ls_stmt        TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_body        TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_branch      TYPE ty_when_branch.
    DATA lv_curr_target TYPE string.
    DATA lv_curr_expr   TYPE string.
    DATA lv_is_assign   TYPE abap_bool.
    DATA lv_has_others  TYPE abap_bool.

    CLEAR: et_branches, ev_target, ev_endcase_idx, ev_valid.
    ev_valid = abap_true.
    lv_curr  = iv_case_idx + 1.

    WHILE lv_curr <= iv_total.
      ls_stmt = zcl_skylint_ast_util=>get_statement( it_statements = it_statements
                                                     iv_index      = lv_curr ).
      IF ls_stmt-keyword IS INITIAL.
        EXIT.
      ENDIF.

      IF ls_stmt-keyword = 'ENDCASE'.
        ev_endcase_idx = lv_curr.
        EXIT.
      ENDIF.

      IF ls_stmt-keyword <> 'WHEN'.
        ev_valid = abap_false.
        EXIT.
      ENDIF.

      CLEAR ls_branch.
      ls_branch-when_idx = lv_curr.

      IF is_when_others( ls_stmt ) = abap_true.
        ls_branch-is_others = abap_true.
        lv_has_others = abap_true.
      ELSE.
        ls_branch-cond_text = extract_tokens_text( is_statement = ls_stmt
                                                   iv_from_idx  = 2
                                                   iv_to_idx    = lines( ls_stmt-tokens ) ).
      ENDIF.

      lv_curr += 1.
      IF lv_curr > iv_total.
        ev_valid = abap_false.
        EXIT.
      ENDIF.

      ls_body = zcl_skylint_ast_util=>get_statement( it_statements = it_statements
                                                     iv_index      = lv_curr ).
      parse_assignment( EXPORTING is_statement = ls_body
                        IMPORTING ev_target    = lv_curr_target
                                  ev_expr      = lv_curr_expr
                                  ev_is_assign = lv_is_assign ).

      IF lv_is_assign = abap_false.
        ev_valid = abap_false.
        EXIT.
      ENDIF.

      IF ev_target IS INITIAL.
        ev_target = lv_curr_target.
      ELSEIF ev_target <> lv_curr_target.
        ev_valid = abap_false.
        EXIT.
      ENDIF.

      ls_branch-target_var = lv_curr_target.
      ls_branch-expr_text  = lv_curr_expr.
      APPEND ls_branch TO et_branches.

      IF ls_branch-is_others = abap_true.
        lv_curr += 1.
        IF lv_curr <= iv_total.
          ls_stmt = zcl_skylint_ast_util=>get_statement( it_statements = it_statements
                                                         iv_index      = lv_curr ).
          IF ls_stmt-keyword = 'ENDCASE'.
            ev_endcase_idx = lv_curr.
            EXIT.
          ENDIF.
        ENDIF.
        ev_valid = abap_false.
        EXIT.
      ENDIF.

      lv_curr += 1.
    ENDWHILE.

    IF mv_require_others = abap_true AND lv_has_others = abap_false.
      ev_valid = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD is_when_others.
    rv_is = zcl_skylint_ast_util=>matches_token_at( is_statement = is_statement
                                                    iv_index     = 2
                                                    iv_expected  = `OTHERS` ).
  ENDMETHOD.

  METHOD parse_assignment.
    DATA lv_tok_count TYPE i.
    DATA ls_first     TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA ls_second    TYPE if_ci_atc_source_code_provider=>ty_token.

    CLEAR: ev_target, ev_expr, ev_is_assign.

    IF is_statement-keyword <> 'COMPUTE'.
      RETURN.
    ENDIF.

    lv_tok_count = lines( is_statement-tokens ).
    IF lv_tok_count < 3.
      RETURN.
    ENDIF.

    ls_first = zcl_skylint_ast_util=>get_first_token( is_statement ).
    ls_second = zcl_skylint_ast_util=>get_token( is_statement = is_statement
                                                 iv_index     = 2 ).

    IF ls_second-lexeme <> '='.
      RETURN.
    ENDIF.

    ev_target = ls_first-lexeme.
    ev_expr   = extract_tokens_text( is_statement = is_statement
                                     iv_from_idx  = 3
                                     iv_to_idx    = lv_tok_count ).
    ev_is_assign = abap_true.
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

    rv_text = concat_lines_of(
        table = lt_parts
        sep   = ` ` ).
  ENDMETHOD.

  METHOD build_switch_code.
    DATA lv_operand   TYPE string.
    DATA lv_num_tok   TYPE i.
    DATA ls_first_tok TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_indent    TYPE string.
    DATA lv_line      TYPE string.
    FIELD-SYMBOLS <ls_branch> TYPE ty_when_branch.

    CLEAR rt_code.
    lv_num_tok = lines( is_case_stmt-tokens ).
    IF lv_num_tok >= 2.
      lv_operand = extract_tokens_text( is_statement = is_case_stmt
                                        iv_from_idx  = 2
                                        iv_to_idx    = lv_num_tok ).
    ENDIF.

    ls_first_tok = zcl_skylint_ast_util=>get_first_token( is_case_stmt ).
    IF ls_first_tok-position-column > 1.
      lv_indent = repeat(
          val = ` `
          occ = ls_first_tok-position-column - 1 ).
    ENDIF.

    APPEND |{ lv_indent }{ iv_target } = SWITCH #( { lv_operand }| TO rt_code.

    LOOP AT it_branches ASSIGNING <ls_branch>.
      IF <ls_branch>-is_others = abap_true.
        APPEND |{ lv_indent }  ELSE { <ls_branch>-expr_text } ).| TO rt_code.
        RETURN.
      ELSE.
        lv_line = |{ lv_indent }  WHEN { <ls_branch>-cond_text } THEN { <ls_branch>-expr_text }|.
        IF sy-tabix = lines( it_branches ).
          " Last branch without OTHERS: retain current value in ELSE
          APPEND lv_line TO rt_code.
          APPEND |{ lv_indent }  ELSE { iv_target } ).| TO rt_code.
        ELSE.
          APPEND lv_line TO rt_code.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
