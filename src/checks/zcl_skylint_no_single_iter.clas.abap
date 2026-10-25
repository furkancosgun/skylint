CLASS zcl_skylint_no_single_iter DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        single_iter TYPE if_ci_atc_check=>ty_finding_code VALUE 'NO_1_LOOP',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NO_SINGLE_ITER'.

ENDCLASS.


CLASS zcl_skylint_no_single_iter IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid Loops That Execute At Most Once'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-single_iter
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Loop contains an unconditional EXIT or RETURN and executes at most once'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_loop_depth TYPE i.
    DATA lv_ctrl_depth TYPE i.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'LOOP' OR 'WHILE' OR 'DO'.
          lv_loop_depth += 1.
          lv_ctrl_depth = 0.
        WHEN 'ENDLOOP' OR 'ENDWHILE' OR 'ENDDO'.
          IF lv_loop_depth > 0.
            lv_loop_depth -= 1.
          ENDIF.
          lv_ctrl_depth = 0.
        WHEN 'IF' OR 'CASE' OR 'TRY'.
          IF lv_loop_depth > 0.
            lv_ctrl_depth += 1.
          ENDIF.
        WHEN 'ENDIF' OR 'ENDCASE' OR 'ENDTRY'.
          IF lv_loop_depth > 0 AND lv_ctrl_depth > 0.
            lv_ctrl_depth -= 1.
          ENDIF.
        WHEN 'EXIT' OR 'RETURN'.
          IF lv_loop_depth > 0 AND lv_ctrl_depth = 0.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-single_iter ).
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
