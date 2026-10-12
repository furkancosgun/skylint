CLASS zcl_skylint_check_013 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        check_in_loop TYPE if_ci_atc_check=>ty_finding_code VALUE 'CHKINLOOP',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        use_guard TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'IFGUARD',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    METHODS build_guard_lines
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
      RETURNING VALUE(rt_lines) TYPE zcl_skylint_check_base=>ty_code_lines.
ENDCLASS.


CLASS zcl_skylint_check_013 IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Avoid CHECK in loop/iteration structures (prefer IF ... CONTINUE)'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code     = c_finding_codes-check_in_loop
                                       severity = if_ci_atc_check=>finding_severities-warning
                                       text     = 'Avoid CHECK inside loop; use IF ... CONTINUE instead' ) )
                                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-use_guard
                                                                short_text = 'Use IF NOT ... CONTINUE' ) ) ) ).
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
          IF lv_loop_depth > 0.
            CLEAR ls_quickfix.
            lt_new_code = build_guard_lines( <ls_statement> ).
            IF lt_new_code IS NOT INITIAL.
              ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-use_guard
                                              iv_statement_from = lv_stmt_idx
                                              it_new_code       = lt_new_code ).
            ENDIF.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-check_in_loop
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
      lv_lex = zcl_skylint_ast_util=>get_token_lexeme( is_statement      = is_statement
                                                       iv_index          = lv_idx
                                                       iv_case_sensitive = abap_true ).
      IF lv_lex IS INITIAL.
        RETURN.
      ENDIF.
      IF lv_cond IS INITIAL.
        lv_cond = lv_lex.
      ELSE.
        lv_cond = lv_cond && ` ` && lv_lex.
      ENDIF.
      lv_idx += 1.
    ENDWHILE.

    lv_indent = repeat( val = ` `
                        occ = is_statement-position-column ).
    lv_inner = lv_indent && `  `.
    APPEND |{ lv_indent }IF NOT ( { lv_cond } ).| TO rt_lines.
    APPEND |{ lv_inner }CONTINUE.| TO rt_lines.
    APPEND |{ lv_indent }ENDIF.| TO rt_lines.
  ENDMETHOD.
ENDCLASS.
