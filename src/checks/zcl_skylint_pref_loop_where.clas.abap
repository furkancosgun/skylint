CLASS zcl_skylint_pref_loop_where DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        add_where TYPE if_ci_atc_check=>ty_finding_code VALUE 'PREF_LOOPW',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'PREF_LOOP_WHERE'.

    DATA ms_loop_statement TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA mv_pending     TYPE abap_bool.
    DATA mv_guard_open  TYPE abap_bool.
    DATA mv_guard_depth TYPE i.
    DATA mv_guard_cont  TYPE abap_bool.
    DATA mv_guard_other TYPE abap_bool.

    METHODS reset_guard.
    METHODS close_guard.

ENDCLASS.


CLASS zcl_skylint_pref_loop_where IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Filter LOOP AT With a WHERE Clause'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-add_where
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Loop starts with an IF CONTINUE guard - filter rows with WHERE instead'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    IF is_procedure-id-kind = if_ci_atc_source_code_provider=>procedure_kinds-class_definition.
      RETURN.
    ENDIF.

    reset_guard( ).
    mv_pending = abap_false.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'LOOP'.
          " Every LOOP opens a fresh candidate; a still-open guard belongs
          " to the previous loop and has already become invalid ( other )
          ms_loop_statement = <ls_statement>.
          mv_pending = abap_true.
          reset_guard( ).
        WHEN 'IF'.
          IF mv_guard_open = abap_true.
            " nested IF inside the guard - no longer a pure filter
            mv_pending = abap_false.
            mv_guard_other = abap_true.
            mv_guard_depth += 1.
          ELSEIF mv_pending = abap_true.
            " first statement after LOOP: candidate guard
            mv_pending = abap_false.
            mv_guard_open = abap_true.
            mv_guard_depth = 1.
            mv_guard_cont  = abap_false.
            mv_guard_other = abap_false.
          ELSE.
            mv_pending = abap_false.
          ENDIF.
        WHEN 'CASE' OR 'TRY' OR 'DO' OR 'WHILE' OR 'AT' OR 'SELECT'.
          mv_pending = abap_false.
          IF mv_guard_open = abap_true.
            mv_guard_other = abap_true.
            mv_guard_depth += 1.
          ENDIF.
        WHEN 'ENDIF' OR 'ENDCASE' OR 'ENDTRY' OR 'ENDDO' OR 'ENDWHILE'
             OR 'ENDLOOP' OR 'ENDAT' OR 'ENDSELECT'.
          mv_pending = abap_false.
          IF mv_guard_open = abap_true.
            mv_guard_depth -= 1.
            IF mv_guard_depth = 0.
              close_guard( ).
            ENDIF.
          ENDIF.
        WHEN 'CONTINUE'.
          mv_pending = abap_false.
          IF mv_guard_open = abap_true.
            IF mv_guard_depth = 1.
              mv_guard_cont = abap_true.
            ELSE.
              mv_guard_other = abap_true.
            ENDIF.
          ENDIF.
        WHEN OTHERS.
          mv_pending = abap_false.
          IF mv_guard_open = abap_true.
            mv_guard_other = abap_true.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD reset_guard.
    mv_guard_open  = abap_false.
    mv_guard_depth = 0.
    mv_guard_cont  = abap_false.
    mv_guard_other = abap_false.
  ENDMETHOD.

  METHOD close_guard.
    mv_guard_open = abap_false.
    mv_guard_depth = 0.
    IF    mv_guard_cont = abap_true
       AND mv_guard_other = abap_false.
      report_statement( is_statement    = ms_loop_statement
                        iv_finding_code = c_finding_codes-add_where ).
    ENDIF.
    mv_guard_cont  = abap_false.
    mv_guard_other = abap_false.
  ENDMETHOD.
ENDCLASS.
