CLASS zcl_skylint_pref_return DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        exit_outside_loop TYPE if_ci_atc_check=>ty_finding_code VALUE 'EXITOUTLP',
      END OF c_finding_codes.
    CONSTANTS:
      BEGIN OF c_quickfix_codes,
        prefer_return TYPE cl_ci_atc_quickfixes=>ty_quickfix_code VALUE 'EXIT2RET',
      END OF c_quickfix_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'RETURN'.
ENDCLASS.


CLASS zcl_skylint_pref_return IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Prefer RETURN over EXIT outside loop constructs'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     ( code     = c_finding_codes-exit_outside_loop
                                       severity = if_ci_atc_check=>finding_severities-warning
                                       text     = 'Use RETURN instead of EXIT when leaving a procedure'
                                       pseudo_comment = c_pseudo_comment ) )
                                 quickfix_codes    = VALUE #( ( code       = c_quickfix_codes-prefer_return
                                                                short_text = 'Replace EXIT with RETURN' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_loop_depth TYPE i.
    DATA lv_stmt_idx   TYPE i.
    DATA lv_line       TYPE string.
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

        WHEN 'EXIT'.
          IF lv_loop_depth = 0.
            CLEAR ls_quickfix.
            IF zcl_skylint_ast_util=>token_count( <ls_statement> ) = 1.
              lv_line = |{ repeat( val = ` `
                                   occ = <ls_statement>-position-column ) }RETURN.|.
              ls_quickfix = quickfix_replace( iv_quickfix_code  = c_quickfix_codes-prefer_return
                                              iv_statement_from = lv_stmt_idx
                                              it_new_code       = VALUE #( ( lv_line ) ) ).
            ENDIF.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-exit_outside_loop
                              is_quickfix     = ls_quickfix ).
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
