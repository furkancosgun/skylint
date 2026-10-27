CLASS zcl_skylint_pref_cond DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        prefer_cond TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_COND',
      END OF c_finding_codes.

    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        use_cond TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'USECOND',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_COND'.

    DATA mv_require_else TYPE abap_bool VALUE abap_false.

    TYPES:
      BEGIN OF ty_cond_branch,
        branch_idx TYPE i,
        is_else    TYPE abap_bool,
        cond_text  TYPE string,
        target_var TYPE string,
        expr_text  TYPE string,
      END OF ty_cond_branch,
      ty_cond_branches TYPE STANDARD TABLE OF ty_cond_branch WITH EMPTY KEY.

    METHODS build_cond_code
      IMPORTING is_if_stmt     TYPE if_ci_atc_source_code_provider=>ty_statement
                it_branches    TYPE ty_cond_branches
                iv_target      TYPE string
      RETURNING VALUE(rt_code) TYPE zcl_skylint_check_base=>ty_code_lines.

    METHODS scan_cond_branches
      IMPORTING is_if_stmt    TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_if_idx     TYPE i
                it_statements TYPE if_ci_atc_source_code_provider=>ty_statements
                iv_total      TYPE i
      EXPORTING et_branches   TYPE ty_cond_branches
                ev_target     TYPE string
                ev_endif_idx  TYPE i
                ev_valid      TYPE abap_bool.

ENDCLASS.


CLASS zcl_skylint_pref_cond IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #(
            description       = 'Prefer COND #( ) expression over IF/ELSEIF/ELSE statement'
            remote_enablement = abap_true
            finding_codes     = VALUE #( ( code           = c_finding_codes-prefer_cond
                                           severity       = if_ci_atc_check=>finding_severities-warning
                                           text           = 'Prefer COND #( ) constructor expression over IF/ELSEIF'
                                           pseudo_comment = c_pseudo_comment ) )
            quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-use_cond
                                           short_text = 'Replace IF with COND #( )' ) )
            attributes        = VALUE #( ( name  = 'REQUIRE_ELSE'
                                           kind  = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                           value = REF #( mv_require_else ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_idx       TYPE i.
    DATA lv_total     TYPE i.
    DATA lt_branches  TYPE ty_cond_branches.
    DATA lv_target    TYPE string.
    DATA lv_endif_idx TYPE i.
    DATA lv_valid     TYPE abap_bool.
    DATA ls_quickfix  TYPE zcl_skylint_check_base=>ty_quickfix.
    DATA lt_new_code  TYPE zcl_skylint_check_base=>ty_code_lines.
    FIELD-SYMBOLS <ls_if> TYPE if_ci_atc_source_code_provider=>ty_statement.

    lv_total = zcl_skylint_ast_util=>statement_count( is_procedure-statements ).

    LOOP AT is_procedure-statements ASSIGNING <ls_if>.
      IF <ls_if>-keyword <> 'IF'.
        CONTINUE.
      ENDIF.

      IF lines( <ls_if>-tokens ) < 2.
        CONTINUE.
      ENDIF.

      lv_idx = sy-tabix.

      scan_cond_branches( EXPORTING is_if_stmt    = <ls_if>
                                    iv_if_idx     = lv_idx
                                    it_statements = is_procedure-statements
                                    iv_total      = lv_total
                          IMPORTING et_branches   = lt_branches
                                    ev_target     = lv_target
                                    ev_endif_idx  = lv_endif_idx
                                    ev_valid      = lv_valid ).

      IF lv_valid = abap_false OR lv_endif_idx = 0 OR lines( lt_branches ) = 0.
        CONTINUE.
      ENDIF.

      lt_new_code = build_cond_code( is_if_stmt  = <ls_if>
                                     it_branches = lt_branches
                                     iv_target   = lv_target ).

      ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-use_cond
                                      iv_statement_from = lv_idx
                                      iv_statement_to   = lv_endif_idx
                                      it_new_code       = lt_new_code ).

      report_statement( is_statement    = <ls_if>
                        iv_finding_code = c_finding_codes-prefer_cond
                        is_quickfix     = ls_quickfix ).
    ENDLOOP.
  ENDMETHOD.

  METHOD scan_cond_branches.
    DATA lv_curr        TYPE i.
    DATA ls_stmt        TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_body        TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_branch      TYPE ty_cond_branch.
    DATA lv_curr_target TYPE string.
    DATA lv_curr_expr   TYPE string.
    DATA lv_is_assign   TYPE abap_bool.
    DATA lv_has_else    TYPE abap_bool.

    CLEAR: et_branches,
           ev_target,
           ev_endif_idx,
           ev_valid.
    ev_valid = abap_true.

    CLEAR ls_branch.
    ls_branch-branch_idx = iv_if_idx.
    ls_branch-cond_text  = zcl_skylint_ast_util=>extract_tokens_text( is_statement = is_if_stmt
                                                                      iv_from_idx  = 2
                                                                      iv_to_idx    = lines( is_if_stmt-tokens ) ).

    lv_curr = iv_if_idx + 1.
    IF lv_curr > iv_total.
      ev_valid = abap_false.
      RETURN.
    ENDIF.

    ls_body = zcl_skylint_ast_util=>get_statement( it_statements = it_statements
                                                   iv_index      = lv_curr ).
    zcl_skylint_ast_util=>parse_assignment( EXPORTING is_statement     = ls_body
                                            IMPORTING ev_target        = lv_curr_target
                                                      ev_expr          = lv_curr_expr
                                                      ev_is_assignment = lv_is_assign ).

    IF lv_is_assign = abap_false.
      ev_valid = abap_false.
      RETURN.
    ENDIF.

    ev_target            = lv_curr_target.
    ls_branch-target_var = lv_curr_target.
    ls_branch-expr_text  = lv_curr_expr.
    APPEND ls_branch TO et_branches.

    lv_curr += 1.

    WHILE lv_curr <= iv_total.
      ls_stmt = zcl_skylint_ast_util=>get_statement( it_statements = it_statements
                                                     iv_index      = lv_curr ).
      IF ls_stmt-keyword IS INITIAL.
        EXIT.
      ENDIF.

      IF ls_stmt-keyword = 'ENDIF'.
        ev_endif_idx = lv_curr.
        EXIT.
      ENDIF.

      IF ls_stmt-keyword <> 'ELSEIF' AND ls_stmt-keyword <> 'ELSE'.
        ev_valid = abap_false.
        EXIT.
      ENDIF.

      CLEAR ls_branch.
      ls_branch-branch_idx = lv_curr.

      IF ls_stmt-keyword = 'ELSE'.
        ls_branch-is_else = abap_true.
        lv_has_else       = abap_true.
      ELSE.
        ls_branch-cond_text = zcl_skylint_ast_util=>extract_tokens_text( is_statement = ls_stmt
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
      zcl_skylint_ast_util=>parse_assignment( EXPORTING is_statement     = ls_body
                                              IMPORTING ev_target        = lv_curr_target
                                                        ev_expr          = lv_curr_expr
                                                        ev_is_assignment = lv_is_assign ).

      IF lv_is_assign = abap_false OR lv_curr_target <> ev_target.
        ev_valid = abap_false.
        EXIT.
      ENDIF.

      ls_branch-target_var = lv_curr_target.
      ls_branch-expr_text  = lv_curr_expr.
      APPEND ls_branch TO et_branches.

      IF ls_branch-is_else = abap_true.
        lv_curr += 1.
        IF lv_curr <= iv_total.
          ls_stmt = zcl_skylint_ast_util=>get_statement( it_statements = it_statements
                                                         iv_index      = lv_curr ).
          IF ls_stmt-keyword = 'ENDIF'.
            ev_endif_idx = lv_curr.
            EXIT.
          ENDIF.
        ENDIF.
        ev_valid = abap_false.
        EXIT.
      ENDIF.

      lv_curr += 1.
    ENDWHILE.

    IF mv_require_else = abap_true AND lv_has_else = abap_false.
      ev_valid = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD build_cond_code.
    DATA ls_first_tok TYPE if_ci_atc_source_code_provider=>ty_token.
    DATA lv_indent    TYPE string.
    DATA lv_line      TYPE string.
    FIELD-SYMBOLS <ls_branch> TYPE ty_cond_branch.

    CLEAR rt_code.
    ls_first_tok = zcl_skylint_ast_util=>get_first_token( is_if_stmt ).
    IF ls_first_tok-position-column > 1.
      lv_indent = repeat( val = ` `
                          occ = ls_first_tok-position-column - 1 ).
    ENDIF.

    APPEND |{ lv_indent }{ iv_target } = COND #( | TO rt_code.

    LOOP AT it_branches ASSIGNING <ls_branch>.
      IF <ls_branch>-is_else = abap_true.
        APPEND |{ lv_indent }  ELSE { <ls_branch>-expr_text } ).| TO rt_code.
        RETURN.
      ENDIF.

      lv_line = |{ lv_indent }  WHEN { <ls_branch>-cond_text } THEN { <ls_branch>-expr_text }|.
      IF sy-tabix = lines( it_branches ).
        APPEND lv_line TO rt_code.
        APPEND |{ lv_indent }  ELSE { iv_target } ).| TO rt_code.
      ELSE.
        APPEND lv_line TO rt_code.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
