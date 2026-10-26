CLASS zcl_skylint_pref_early_ret DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        guard_method TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_GRDMT',
        guard_loop   TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_GRDLP',
        else_exit    TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_ELSEEXT',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS:
      BEGIN OF c_pseudo_comments,
        early_return   TYPE string VALUE 'PREF_GUARD_METHOD',
        early_continue TYPE string VALUE 'PREF_GUARD_LOOP',
        else_exit      TYPE string VALUE 'PREF_NO_ELSE_EXIT',
      END OF c_pseudo_comments.

    DATA mv_check_method_return TYPE abap_bool VALUE abap_true.
    DATA mv_check_loop_continue TYPE abap_bool VALUE abap_true.
    DATA mv_report_elseif TYPE abap_bool VALUE abap_false.

    METHODS is_after_terminator
      IMPORTING it_statements TYPE if_ci_atc_source_code_provider=>ty_statements
                iv_index      TYPE i
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    METHODS is_terminator
      IMPORTING iv_keyword    TYPE string
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    METHODS get_first_executable_stmt
      IMPORTING it_statements TYPE if_ci_atc_source_code_provider=>ty_statements
      EXPORTING ev_index      TYPE i
                es_statement  TYPE if_ci_atc_source_code_provider=>ty_statement.

    METHODS if_wraps_method_end
      IMPORTING it_statements TYPE if_ci_atc_source_code_provider=>ty_statements
                iv_if_idx     TYPE i
      RETURNING VALUE(rv_yes) TYPE abap_bool.

    METHODS find_wrapping_if
      IMPORTING it_statements TYPE if_ci_atc_source_code_provider=>ty_statements
                iv_loop_idx   TYPE i
      RETURNING VALUE(rs_if)  TYPE if_ci_atc_source_code_provider=>ty_statement.
ENDCLASS.


CLASS zcl_skylint_pref_early_ret IMPLEMENTATION.
  METHOD constructor.
    super->constructor( VALUE #( description       = 'Prefer early return or continue over nested IF blocks'
                                 remote_enablement = abap_true
                                 finding_codes     = VALUE #(
                                     severity = if_ci_atc_check=>finding_severities-warning
                                     ( code           = c_finding_codes-guard_method
                                       text           = 'Invert IF condition and use RETURN to reduce nesting in method'
                                       pseudo_comment = c_pseudo_comments-early_return )
                                     ( code           = c_finding_codes-guard_loop
                                       text           = 'Invert IF condition and use CONTINUE to reduce nesting in loop'
                                       pseudo_comment = c_pseudo_comments-early_continue )
                                     ( code           = c_finding_codes-else_exit
                                       text           = 'Remove ELSE after a terminating statement'
                                       pseudo_comment = c_pseudo_comments-else_exit ) )
                                 attributes        = VALUE #( kind = if_ci_atc_check_meta_data=>attribute_kinds-boolean
                                                              ( name  = 'CHECK_METHOD_RETURN'
                                                                value = REF #( mv_check_method_return ) )
                                                              ( name  = 'CHECK_LOOP_CONTINUE'
                                                                value = REF #( mv_check_loop_continue ) )
                                                              ( name  = 'REPORT_ELSEIF'
                                                                value = REF #( mv_report_elseif ) ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_first_idx  TYPE i.
    DATA ls_first_stmt TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_if         TYPE if_ci_atc_source_code_provider=>ty_statement.

    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF mv_check_method_return = abap_true.
      get_first_executable_stmt( EXPORTING it_statements = is_procedure-statements
                                 IMPORTING ev_index      = lv_first_idx
                                           es_statement  = ls_first_stmt ).

      IF     ls_first_stmt-keyword = 'IF'
         AND lv_first_idx > 0
         AND if_wraps_method_end( it_statements = is_procedure-statements
                                  iv_if_idx     = lv_first_idx )          = abap_true.
        report_statement( is_statement    = ls_first_stmt
                          iv_finding_code = c_finding_codes-guard_method ).
      ENDIF.
    ENDIF.

    IF mv_check_loop_continue = abap_true.
      LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
        IF     <ls_statement>-keyword <> 'LOOP'
           AND <ls_statement>-keyword <> 'DO'
           AND <ls_statement>-keyword <> 'WHILE'.
          CONTINUE.
        ENDIF.
        ls_if = find_wrapping_if( it_statements = is_procedure-statements
                                  iv_loop_idx   = sy-tabix ).
        IF ls_if-keyword = 'IF'.
          report_statement( is_statement    = ls_if
                            iv_finding_code = c_finding_codes-guard_loop ).
        ENDIF.
      ENDLOOP.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'ELSE'.
          IF is_after_terminator( it_statements = is_procedure-statements
                                  iv_index      = sy-tabix ) = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-else_exit ).
          ENDIF.
        WHEN 'ELSEIF'.
          IF     mv_report_elseif = abap_true
             AND is_after_terminator( it_statements = is_procedure-statements
                                      iv_index      = sy-tabix ) = abap_true.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-else_exit ).
          ENDIF.
        WHEN OTHERS.
          CONTINUE.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_first_executable_stmt.
    DATA lv_max  TYPE i.
    DATA lv_idx  TYPE i.
    DATA ls_stmt TYPE if_ci_atc_source_code_provider=>ty_statement.

    CLEAR ev_index.
    CLEAR es_statement.

    lv_max = zcl_skylint_ast_util=>statement_count( it_statements ).
    IF lv_max < 3.
      RETURN.
    ENDIF.

    DO lv_max TIMES.
      lv_idx = sy-index.
      ls_stmt = zcl_skylint_ast_util=>get_statement( it_statements = it_statements
                                                     iv_index      = lv_idx ).
      IF ls_stmt-keyword IS INITIAL.
        CONTINUE.
      ENDIF.

      CASE ls_stmt-keyword.
        WHEN 'METHOD' OR 'DATA' OR 'TYPES' OR 'CONSTANTS' OR 'STATICS' OR 'FIELD-SYMBOLS'.
          CONTINUE.
        WHEN OTHERS.
          es_statement = ls_stmt.
          ev_index     = lv_idx.
          RETURN.
      ENDCASE.
    ENDDO.
  ENDMETHOD.

  METHOD if_wraps_method_end.
    DATA lv_max      TYPE i.
    DATA lv_if_depth TYPE i.
    DATA lv_has_else TYPE abap_bool.
    DATA lv_scan_idx TYPE i.
    DATA ls_stmt     TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_after    TYPE if_ci_atc_source_code_provider=>ty_statement.

    rv_yes = abap_false.
    lv_max = zcl_skylint_ast_util=>statement_count( it_statements ).
    lv_if_depth = 1.
    lv_has_else = abap_false.
    lv_scan_idx = iv_if_idx + 1.

    WHILE lv_scan_idx <= lv_max AND lv_if_depth > 0.
      ls_stmt = zcl_skylint_ast_util=>get_statement( it_statements = it_statements
                                                     iv_index      = lv_scan_idx ).
      IF ls_stmt-keyword IS INITIAL.
        EXIT.
      ENDIF.

      CASE ls_stmt-keyword.
        WHEN 'IF'.
          lv_if_depth += 1.
        WHEN 'ELSE' OR 'ELSEIF'.
          IF lv_if_depth = 1.
            lv_has_else = abap_true.
          ENDIF.
        WHEN 'ENDIF'.
          lv_if_depth -= 1.
          IF lv_if_depth = 0.
            IF lv_scan_idx = lv_max.
              rv_yes = abap_true.
            ELSE.
              ls_after = zcl_skylint_ast_util=>get_next_statement( it_statements    = it_statements
                                                                   iv_current_index = lv_scan_idx ).
              IF lv_has_else = abap_false AND ls_after-keyword = 'ENDMETHOD'.
                rv_yes = abap_true.
              ENDIF.
            ENDIF.
            RETURN.
          ENDIF.
      ENDCASE.
      lv_scan_idx += 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD find_wrapping_if.
    DATA lv_max      TYPE i.
    DATA lv_if_depth TYPE i.
    DATA lv_has_else TYPE abap_bool.
    DATA lv_scan_idx TYPE i.
    DATA ls_first    TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_stmt     TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_after    TYPE if_ci_atc_source_code_provider=>ty_statement.

    CLEAR rs_if.
    lv_max = zcl_skylint_ast_util=>statement_count( it_statements ).
    IF iv_loop_idx + 3 > lv_max.
      RETURN.
    ENDIF.

    ls_first = zcl_skylint_ast_util=>get_next_statement( it_statements    = it_statements
                                                         iv_current_index = iv_loop_idx ).
    IF ls_first-keyword <> 'IF'.
      RETURN.
    ENDIF.

    lv_if_depth = 1.
    lv_has_else = abap_false.
    lv_scan_idx = iv_loop_idx + 2.

    WHILE lv_scan_idx <= lv_max AND lv_if_depth > 0.
      ls_stmt = zcl_skylint_ast_util=>get_statement( it_statements = it_statements
                                                     iv_index      = lv_scan_idx ).
      IF ls_stmt-keyword IS INITIAL.
        EXIT.
      ENDIF.

      CASE ls_stmt-keyword.
        WHEN 'IF'.
          lv_if_depth += 1.
        WHEN 'ELSE' OR 'ELSEIF'.
          IF lv_if_depth = 1.
            lv_has_else = abap_true.
          ENDIF.
        WHEN 'ENDIF'.
          lv_if_depth -= 1.
          IF lv_if_depth = 0.
            ls_after = zcl_skylint_ast_util=>get_next_statement( it_statements    = it_statements
                                                                 iv_current_index = lv_scan_idx ).
            IF     lv_has_else = abap_false
               AND ( ls_after-keyword = 'ENDLOOP' OR ls_after-keyword = 'ENDDO' OR ls_after-keyword = 'ENDWHILE' ).
              rs_if = ls_first.
            ENDIF.
            EXIT.
          ENDIF.
      ENDCASE.
      lv_scan_idx += 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD is_after_terminator.
    DATA ls_previous TYPE if_ci_atc_source_code_provider=>ty_statement.

    rv_yes = abap_false.
    ls_previous = zcl_skylint_ast_util=>get_previous_statement( it_statements    = it_statements
                                                                 iv_current_index = iv_index ).
    IF ls_previous-keyword IS INITIAL.
      RETURN.
    ENDIF.
    rv_yes = is_terminator( ls_previous-keyword ).
  ENDMETHOD.

  METHOD is_terminator.
    CASE iv_keyword.
      WHEN 'RETURN' OR 'RAISE' OR 'EXIT' OR 'CONTINUE' OR 'LEAVE'.
        rv_yes = abap_true.
      WHEN OTHERS.
        rv_yes = abap_false.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
