CLASS zcl_skylint_no_late_sys_idx DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        late_sys_idx TYPE if_ci_atc_check=>ty_finding_code VALUE 'LATE_INDEX',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_LATE_SYS_IDX'.

    METHODS inspect_statement
      IMPORTING is_statement  TYPE if_ci_atc_source_code_provider=>ty_statement
                iv_field_name TYPE string.

ENDCLASS.


CLASS zcl_skylint_no_late_sys_idx IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid late access to sy-tabix or sy-index inside loops'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #( ( code           = c_finding_codes-late_sys_idx
                                                severity       = if_ci_atc_check=>finding_severities-warning
                                                text           = 'Copy sy-tabix or sy-index immediately at loop start'
                                                pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_loop_depth TYPE i.
    DATA lv_do_depth   TYPE i.
    DATA ls_prev_stmt  TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      ls_prev_stmt = zcl_skylint_ast_util=>get_previous_statement(
                         it_statements    = is_procedure-statements
                         iv_current_index = sy-tabix ).

      IF lv_loop_depth > 0 AND ls_prev_stmt-keyword <> 'LOOP'.
        inspect_statement( is_statement  = <ls_statement>
                           iv_field_name = 'TABIX' ).
      ENDIF.

      IF     lv_do_depth > 0
         AND ls_prev_stmt-keyword <> 'DO'
         AND ls_prev_stmt-keyword <> 'WHILE'.
        inspect_statement( is_statement  = <ls_statement>
                           iv_field_name = 'INDEX' ).
      ENDIF.

      CASE <ls_statement>-keyword.
        WHEN 'LOOP'.
          lv_loop_depth += 1.
        WHEN 'ENDLOOP'.
          IF lv_loop_depth > 0.
            lv_loop_depth -= 1.
          ENDIF.
        WHEN 'DO' OR 'WHILE'.
          lv_do_depth += 1.
        WHEN 'ENDDO' OR 'ENDWHILE'.
          IF lv_do_depth > 0.
            lv_do_depth -= 1.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD inspect_statement.
    FIELD-SYMBOLS <ls_token> TYPE if_ci_atc_source_code_provider=>ty_token.

    LOOP AT is_statement-tokens ASSIGNING <ls_token>.
      IF zcl_skylint_ast_util=>match_system_field( is_token      = <ls_token>
                                                   iv_field_name = iv_field_name ) = abap_true.
        report_token( is_token        = <ls_token>
                      is_statement    = is_statement
                      iv_finding_code = c_finding_codes-late_sys_idx ).
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
