CLASS zcl_skylint_pref_case DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        change_if_to_case TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_CASE',
      END OF c_finding_codes.

    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        use_case TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'USE_CASE',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_CASE'.

    DATA mv_min_branches TYPE i VALUE 3.

    METHODS get_compared_variable
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_var) TYPE string.

    METHODS get_compared_value
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rv_val) TYPE string.

    METHODS strip_outer_parens
      IMPORTING is_statement TYPE if_ci_atc_source_code_provider=>ty_statement
      CHANGING  cv_from      TYPE i
                cv_to        TYPE i.

    METHODS build_case_quickfixes
      IMPORTING is_procedure TYPE if_ci_atc_source_code_provider=>ty_procedure
                iv_stmt_idx  TYPE i
                iv_var       TYPE string
      RETURNING VALUE(rt_qf) TYPE ty_quickfixes.

ENDCLASS.


CLASS zcl_skylint_pref_case IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Use CASE instead of IF when checking multiple values'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-change_if_to_case
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Multiple ELSEIF branches check the same variable; use CASE instead'
                       pseudo_comment = c_pseudo_comment ) )
                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-use_case
                                                short_text = 'Convert IF/ELSEIF chain to CASE' ) )
                 attributes        = VALUE #( ( name  = 'MIN_BRANCHES'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                                value = REF #( mv_min_branches ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_idx          TYPE i.
    DATA lv_depth        TYPE i.
    DATA lv_total        TYPE i.
    DATA lv_var          TYPE string.
    DATA lv_branch_count TYPE i.
    DATA lv_stmt_idx     TYPE i.
    DATA ls_stmt         TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA lt_qfs          TYPE ty_quickfixes.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    lv_total = lines( is_procedure-statements ).

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_stmt_idx = sy-tabix.
      IF <ls_statement>-keyword <> 'IF'.
        CONTINUE.
      ENDIF.
      lv_var = get_compared_variable( <ls_statement> ).
      IF lv_var IS INITIAL.
        CONTINUE.
      ENDIF.

      lv_branch_count = 1.
      lv_depth = 1.
      lv_idx = lv_stmt_idx + 1.

      WHILE lv_idx <= lv_total AND lv_depth > 0.
        ls_stmt = zcl_skylint_ast_util=>get_statement( it_statements = is_procedure-statements
                                                       iv_index      = lv_idx ).
        CASE ls_stmt-keyword.
          WHEN 'IF'.
            lv_depth += 1.
          WHEN 'ENDIF'.
            lv_depth -= 1.
          WHEN 'ELSEIF'.
            IF lv_depth = 1 AND get_compared_variable( ls_stmt ) = lv_var.
              lv_branch_count += 1.
            ENDIF.
        ENDCASE.
        lv_idx += 1.
      ENDWHILE.

      IF lv_branch_count >= mv_min_branches.
        lt_qfs = build_case_quickfixes( is_procedure = is_procedure
                                        iv_stmt_idx  = lv_stmt_idx
                                        iv_var       = lv_var ).
        report_statement( is_statement    = <ls_statement>
                          iv_finding_code = c_finding_codes-change_if_to_case
                          it_quickfixes   = lt_qfs ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD build_case_quickfixes.
    DATA lv_total   TYPE i.
    DATA lv_depth   TYPE i.
    DATA lv_idx     TYPE i.
    DATA lv_val     TYPE string.
    DATA lv_indent  TYPE string.
    DATA ls_stmt    TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_if_stmt TYPE if_ci_atc_source_code_provider=>ty_statement.

    CLEAR rt_qf.
    lv_total = lines( is_procedure-statements ).
    ls_if_stmt = zcl_skylint_ast_util=>get_statement( it_statements = is_procedure-statements
                                                      iv_index      = iv_stmt_idx ).
    IF ls_if_stmt-position-column > 1.
      lv_indent = repeat( val = ` `
                          occ = ls_if_stmt-position-column - 1 ).
    ELSE.
      lv_indent = ''.
    ENDIF.

    lv_val = get_compared_value( ls_if_stmt ).
    IF lv_val IS INITIAL.
      RETURN.
    ENDIF.

    APPEND quickfix_replace( iv_quickfix_code  = c_quickfix_codes-use_case
                             iv_statement_from = iv_stmt_idx
                             it_new_code       = VALUE #( ( |{ lv_indent }CASE { iv_var }.| )
                                                          ( |{ lv_indent }  WHEN { lv_val }.| ) ) ) TO rt_qf.

    lv_depth = 1.
    lv_idx = iv_stmt_idx + 1.

    WHILE lv_idx <= lv_total AND lv_depth > 0.
      ls_stmt = zcl_skylint_ast_util=>get_statement( it_statements = is_procedure-statements
                                                     iv_index      = lv_idx ).
      CASE ls_stmt-keyword.
        WHEN 'IF'.
          lv_depth += 1.
        WHEN 'ENDIF'.
          lv_depth -= 1.
          IF lv_depth = 0.
            APPEND quickfix_replace( iv_quickfix_code  = c_quickfix_codes-use_case
                                     iv_statement_from = lv_idx
                                     it_new_code       = VALUE #( ( |{ lv_indent }ENDCASE.| ) ) ) TO rt_qf.
          ENDIF.
        WHEN 'ELSEIF'.
          IF lv_depth = 1.
            lv_val = get_compared_value( ls_stmt ).
            IF lv_val IS INITIAL.
              CLEAR rt_qf.
              RETURN.
            ENDIF.
            APPEND quickfix_replace( iv_quickfix_code  = c_quickfix_codes-use_case
                                     iv_statement_from = lv_idx
                                     it_new_code       = VALUE #( ( |{ lv_indent }  WHEN { lv_val }.| ) ) ) TO rt_qf.
          ENDIF.
        WHEN 'ELSE'.
          IF lv_depth = 1.
            APPEND quickfix_replace( iv_quickfix_code  = c_quickfix_codes-use_case
                                     iv_statement_from = lv_idx
                                     it_new_code       = VALUE #( ( |{ lv_indent }  WHEN OTHERS.| ) ) ) TO rt_qf.
          ENDIF.
      ENDCASE.
      lv_idx += 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD get_compared_variable.
    DATA lv_count TYPE i.
    DATA lv_from  TYPE i.
    DATA lv_to    TYPE i.
    DATA lv_depth TYPE i.
    DATA lv_op    TYPE i.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    CLEAR rv_var.
    lv_count = zcl_skylint_ast_util=>token_count( is_statement ).
    IF lv_count < 4.
      RETURN.
    ENDIF.

    lv_from = 2.
    lv_to   = lv_count.
    strip_outer_parens( EXPORTING is_statement = is_statement
                        CHANGING  cv_from      = lv_from
                                  cv_to        = lv_to ).

    IF lv_to < lv_from + 2.
      RETURN.
    ENDIF.

    lv_depth = 0.
    LOOP AT is_statement-tokens FROM lv_from TO lv_to ASSIGNING <ls_token>.
      IF lv_depth = 0 AND <ls_token>-references IS INITIAL.
        IF    <ls_token>-lexeme = 'AND'
           OR <ls_token>-lexeme = 'OR'
           OR <ls_token>-lexeme = 'EQUIV'.
          RETURN.
        ENDIF.
        IF <ls_token>-lexeme = '=' OR <ls_token>-lexeme = 'EQ'.
          IF lv_op > 0.
            RETURN.
          ENDIF.
          lv_op = sy-tabix.
        ENDIF.
      ENDIF.
      lv_depth += zcl_skylint_ast_util=>token_paren_delta( <ls_token> ).
    ENDLOOP.

    IF lv_op <= lv_from OR lv_op >= lv_to.
      RETURN.
    ENDIF.

    LOOP AT is_statement-tokens FROM lv_from TO lv_op - 1 ASSIGNING <ls_token>.
      IF rv_var IS INITIAL.
        rv_var = <ls_token>-lexeme.
      ELSE.
        rv_var = |{ rv_var }{ <ls_token>-lexeme }|.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_compared_value.
    DATA lv_count TYPE i.
    DATA lv_from  TYPE i.
    DATA lv_to    TYPE i.
    DATA lv_depth TYPE i.
    DATA lv_op    TYPE i.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    CLEAR rv_val.
    lv_count = zcl_skylint_ast_util=>token_count( is_statement ).
    IF lv_count < 4.
      RETURN.
    ENDIF.

    lv_from = 2.
    lv_to   = lv_count.
    strip_outer_parens( EXPORTING is_statement = is_statement
                        CHANGING  cv_from      = lv_from
                                  cv_to        = lv_to ).

    lv_depth = 0.
    LOOP AT is_statement-tokens FROM lv_from TO lv_to ASSIGNING <ls_token>.
      IF     lv_depth               = 0
         AND <ls_token>-references IS INITIAL
         AND ( <ls_token>-lexeme = '=' OR <ls_token>-lexeme = 'EQ' ).
        lv_op = sy-tabix.
        EXIT.
      ENDIF.
      lv_depth += zcl_skylint_ast_util=>token_paren_delta( <ls_token> ).
    ENDLOOP.

    IF lv_op <= lv_from OR lv_op >= lv_to.
      RETURN.
    ENDIF.

    LOOP AT is_statement-tokens FROM lv_op + 1 TO lv_to ASSIGNING <ls_token>.
      IF    <ls_token>-lexeme = '('
         OR <ls_token>-lexeme = ')'
         OR <ls_token>-lexeme = '+'
         OR <ls_token>-lexeme = '-'
         OR <ls_token>-lexeme = '*'
         OR <ls_token>-lexeme = '/'
         OR <ls_token>-lexeme = '&&'.
        CLEAR rv_val.
        RETURN.
      ENDIF.
      IF rv_val IS INITIAL.
        rv_val = <ls_token>-lexeme.
      ELSE.
        rv_val = |{ rv_val } { <ls_token>-lexeme }|.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD strip_outer_parens.
    zcl_skylint_ast_util=>strip_outer_parens( EXPORTING is_statement = is_statement
                                              CHANGING  cv_from      = cv_from
                                                        cv_to        = cv_to ).
  ENDMETHOD.
ENDCLASS.
