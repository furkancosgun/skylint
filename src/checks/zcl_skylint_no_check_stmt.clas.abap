CLASS zcl_skylint_no_check_stmt DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        check_in_loop      TYPE if_ci_atc_check=>ty_finding_code VALUE 'CHKINLOOP',
        check_outside_loop TYPE if_ci_atc_check=>ty_finding_code VALUE 'CHKOUTLOOP',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        use_continue TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'IFGUARD',
        use_return   TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'IFRET',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS:
      BEGIN OF c_pseudo_comments,
        check_in_loop      TYPE string VALUE 'CHECK_IN_LOOP',
        check_outside_loop TYPE string VALUE 'CHECK_OUT_LOOP',
      END OF c_pseudo_comments.

    DATA mv_check_in_loop      TYPE abap_bool VALUE abap_true.
    DATA mv_check_outside_loop TYPE abap_bool VALUE abap_true.

    METHODS build_guard_lines
      IMPORTING is_statement    TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_in_loop      TYPE abap_bool
      RETURNING VALUE(rt_lines) TYPE zcl_skylint_check_base=>ty_code_lines.
ENDCLASS.


CLASS zcl_skylint_no_check_stmt IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid CHECK statements; prefer IF with RETURN or CONTINUE'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #( severity = if_ci_atc_check=>finding_severities-warning
                                              ( code           = c_finding_codes-check_in_loop
                                                text           = 'Avoid CHECK inside loop; use IF ... CONTINUE instead'
                                                pseudo_comment = c_pseudo_comments-check_in_loop )
                                              ( code           = c_finding_codes-check_outside_loop
                                                text           = 'Avoid CHECK outside loop; use IF ... RETURN instead'
                                                pseudo_comment = c_pseudo_comments-check_outside_loop ) )
                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-use_continue
                                                short_text = 'Use IF NOT ... CONTINUE' )
                                              ( code       = c_quickfix_codes-use_return
                                                short_text = 'Use IF NOT ... RETURN' ) )
                 attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                              ( name  = 'CHECK_IN_LOOP'
                                                value = REF #( mv_check_in_loop ) )
                                              ( name  = 'CHECK_OUTSIDE_LOOP'
                                                value = REF #( mv_check_outside_loop ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_loop_depth TYPE i.
    DATA lv_stmt_idx   TYPE i.
    DATA lt_new_code   TYPE zcl_skylint_check_base=>ty_code_lines.
    DATA ls_quickfix   TYPE zcl_skylint_check_base=>ty_quickfix.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    lv_loop_depth = 0.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_stmt_idx = sy-tabix.
      CASE <ls_statement>-keyword.
        WHEN 'LOOP' OR 'DO' OR 'WHILE'.
          lv_loop_depth += 1.

        WHEN 'ENDLOOP' OR 'ENDDO' OR 'ENDWHILE'.
          IF lv_loop_depth > 0.
            lv_loop_depth -= 1.
          ENDIF.

        WHEN 'CHECK'.
          IF lv_loop_depth > 0 AND mv_check_in_loop = abap_true.
            CLEAR ls_quickfix.
            lt_new_code = build_guard_lines( is_statement = <ls_statement>
                                             iv_in_loop   = abap_true ).
            IF lt_new_code IS NOT INITIAL.
              ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-use_continue
                                              iv_statement_from = lv_stmt_idx
                                              it_new_code       = lt_new_code ).
            ENDIF.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-check_in_loop
                              is_quickfix     = ls_quickfix ).
          ELSEIF lv_loop_depth = 0 AND mv_check_outside_loop = abap_true.
            CLEAR ls_quickfix.
            lt_new_code = build_guard_lines( is_statement = <ls_statement>
                                             iv_in_loop   = abap_false ).
            IF lt_new_code IS NOT INITIAL.
              ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-use_return
                                              iv_statement_from = lv_stmt_idx
                                              it_new_code       = lt_new_code ).
            ENDIF.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-check_outside_loop
                              is_quickfix     = ls_quickfix ).
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD build_guard_lines.
    DATA lv_count  TYPE i.
    DATA lv_idx    TYPE i.
    DATA lv_cond   TYPE string.
    DATA lv_lex    TYPE string.
    DATA lv_indent TYPE string.
    DATA lv_inner  TYPE string.

    CLEAR rt_lines.
    lv_count = zcl_skylint_ast_util=>token_count( is_statement ).
    IF lv_count < 2.
      RETURN.
    ENDIF.

    lv_cond = ''.
    lv_idx = 2.
    WHILE lv_idx <= lv_count.
      lv_lex = zcl_skylint_ast_util=>get_token_lexeme( is_statement = is_statement
                                                       iv_index     = lv_idx ).
      IF lv_lex IS INITIAL.
        RETURN.
      ENDIF.
      IF lv_cond IS INITIAL.
        lv_cond = lv_lex.
      ELSE.
        lv_cond = |{ lv_cond } { lv_lex }|.
      ENDIF.
      lv_idx += 1.
    ENDWHILE.

    lv_indent = repeat( val = ` `
                        occ = is_statement-position-column ).
    lv_inner = |{ lv_indent }  |.
    APPEND |{ lv_indent }IF NOT ( { lv_cond } ).| TO rt_lines.
    IF iv_in_loop = abap_true.
      APPEND |{ lv_inner }CONTINUE.| TO rt_lines.
    ELSE.
      APPEND |{ lv_inner }RETURN.| TO rt_lines.
    ENDIF.
    APPEND |{ lv_indent }ENDIF.| TO rt_lines.
  ENDMETHOD.
ENDCLASS.
