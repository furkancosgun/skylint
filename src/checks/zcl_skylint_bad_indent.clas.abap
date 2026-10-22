CLASS zcl_skylint_bad_indent DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        bad_indent TYPE if_ci_atc_check=>ty_finding_code VALUE 'BADINDENT',
      END OF c_finding_codes.

    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        indent_stmt TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'FIXINDENT',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'BAD_INDENT'.

    DATA mv_indent_step TYPE i VALUE 2.

    METHODS build_indent_fix
      IMPORTING is_statement    TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_target_col   TYPE i
      RETURNING VALUE(rt_lines) TYPE zcl_skylint_check_base=>ty_code_lines.

ENDCLASS.


CLASS zcl_skylint_bad_indent IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'skylint: Bad Statement Indentation'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #( ( code           = c_finding_codes-bad_indent
                                                severity       = if_ci_atc_check=>finding_severities-warning
                                                text           = 'Statement indentation does not match block nesting'
                                                pseudo_comment = c_pseudo_comment ) )
                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-indent_stmt
                                                short_text = 'Fix statement indentation' ) )
                 attributes        = VALUE #( ( name  = 'INDENT_STEP'
                                                kind  = if_ci_atc_check_meta_data=>attribute_kinds-elementary
                                                value = REF #( mv_indent_step ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_base_col  TYPE i.
    DATA lv_expected  TYPE i.
    DATA lv_stmt_col  TYPE i.
    DATA lv_check_col TYPE i.
    DATA lv_stmt_idx  TYPE i.
    DATA lt_new_code  TYPE zcl_skylint_check_base=>ty_code_lines.
    DATA ls_quickfix  TYPE zcl_skylint_check_base=>ty_quickfix.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    lv_base_col = -1.
    lv_expected = -1.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      lv_stmt_idx = sy-tabix.
      lv_stmt_col = <ls_statement>-position-column.

      IF <ls_statement>-keyword = 'METHOD'.
        lv_base_col = lv_stmt_col.
        lv_expected = lv_base_col + mv_indent_step.
        CONTINUE.
      ENDIF.

      IF <ls_statement>-keyword = 'ENDMETHOD'.
        IF lv_base_col >= 0 AND lv_stmt_col <> lv_base_col.
          lt_new_code = build_indent_fix( is_statement  = <ls_statement>
                                          iv_target_col = lv_base_col ).
          ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-indent_stmt
                                          iv_statement_from = lv_stmt_idx
                                          it_new_code       = lt_new_code ).
          report_statement( is_statement    = <ls_statement>
                            iv_finding_code = c_finding_codes-bad_indent
                            is_quickfix     = ls_quickfix ).
        ENDIF.
        CONTINUE.
      ENDIF.

      IF lv_expected < 0.
        lv_expected = lv_stmt_col.
      ENDIF.

      CASE <ls_statement>-keyword.
        WHEN 'ELSE' OR 'ELSEIF' OR 'WHEN' OR 'CATCH' OR 'CLEANUP'.
          lv_check_col = lv_expected - mv_indent_step.
          IF lv_check_col < 0.
            lv_check_col = 0.
          ENDIF.
          IF lv_stmt_col <> lv_check_col.
            lt_new_code = build_indent_fix( is_statement  = <ls_statement>
                                            iv_target_col = lv_check_col ).
            ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-indent_stmt
                                            iv_statement_from = lv_stmt_idx
                                            it_new_code       = lt_new_code ).
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-bad_indent
                              is_quickfix     = ls_quickfix ).
          ENDIF.

        WHEN 'ENDIF' OR 'ENDLOOP' OR 'ENDDO' OR 'ENDWHILE' OR 'ENDTRY' OR 'ENDCASE'.
          lv_expected -= mv_indent_step.
          IF lv_expected < 0.
            lv_expected = 0.
          ENDIF.
          IF lv_stmt_col <> lv_expected.
            lt_new_code = build_indent_fix( is_statement  = <ls_statement>
                                            iv_target_col = lv_expected ).
            ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-indent_stmt
                                            iv_statement_from = lv_stmt_idx
                                            it_new_code       = lt_new_code ).
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-bad_indent
                              is_quickfix     = ls_quickfix ).
          ENDIF.

        WHEN 'IF' OR 'LOOP' OR 'DO' OR 'WHILE' OR 'TRY' OR 'CASE'.
          IF lv_stmt_col <> lv_expected.
            lt_new_code = build_indent_fix( is_statement  = <ls_statement>
                                            iv_target_col = lv_expected ).
            ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-indent_stmt
                                            iv_statement_from = lv_stmt_idx
                                            it_new_code       = lt_new_code ).
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-bad_indent
                              is_quickfix     = ls_quickfix ).
          ENDIF.
          lv_expected += mv_indent_step.

        WHEN OTHERS.
          IF lv_stmt_col <> lv_expected.
            lt_new_code = build_indent_fix( is_statement  = <ls_statement>
                                            iv_target_col = lv_expected ).
            ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-indent_stmt
                                            iv_statement_from = lv_stmt_idx
                                            it_new_code       = lt_new_code ).
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-bad_indent
                              is_quickfix     = ls_quickfix ).
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD build_indent_fix.
    DATA lv_spaces TYPE string.
    DATA lv_line   TYPE string.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    IF iv_target_col > 0.
      lv_spaces = repeat( val = ` `
                          occ = iv_target_col ).
    ENDIF.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      IF lv_line IS INITIAL.
        lv_line = <ls_token>-lexeme.
      ELSE.
        lv_line = |{ lv_line } { <ls_token>-lexeme }|.
      ENDIF.
    ENDLOOP.

    APPEND |{ lv_spaces }{ lv_line }.| TO rt_lines.
  ENDMETHOD.
ENDCLASS.
