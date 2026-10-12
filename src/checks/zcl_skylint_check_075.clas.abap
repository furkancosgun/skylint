CLASS zcl_skylint_check_075 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        guard_method TYPE if_ci_atc_check=>ty_finding_code VALUE 'GUARD_METH',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.
ENDCLASS.


CLASS zcl_skylint_check_075 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Use early RETURN guard clause instead of wrapping method in IF block'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code     = c_finding_codes-guard_method
                       severity = if_ci_atc_check=>finding_severities-warning
                       text     = 'Invert IF condition and use RETURN to reduce nesting in method' ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_max       TYPE i.
    DATA lv_idx       TYPE i.
    DATA lv_first_idx TYPE i.
    DATA lv_scan_idx  TYPE i.
    DATA lv_if_depth  TYPE i.
    DATA lv_has_else  TYPE abap_bool.
    DATA ls_first     TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_stmt      TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_after     TYPE if_ci_atc_source_code_provider=>ty_statement.

    lv_max = zcl_skylint_ast_util=>statement_count( is_procedure-statements ).
    IF lv_max < 3.
      RETURN.
    ENDIF.

    DO lv_max TIMES.
      lv_idx = sy-index.
      ls_stmt = zcl_skylint_ast_util=>get_statement( it_statements = is_procedure-statements
                                                     iv_index      = lv_idx ).
      IF ls_stmt-keyword IS INITIAL.
        CONTINUE.
      ENDIF.

      CASE ls_stmt-keyword.
        WHEN 'METHOD' OR 'DATA' OR 'TYPES' OR 'CONSTANTS' OR 'STATICS' OR 'FIELD-SYMBOLS'.
          CONTINUE.
        WHEN OTHERS.
          ls_first = ls_stmt.
          lv_first_idx = lv_idx.
          EXIT.
      ENDCASE.
    ENDDO.

    IF ls_first-keyword <> 'IF' OR lv_first_idx = 0.
      RETURN.
    ENDIF.

    lv_if_depth = 1.
    lv_has_else = abap_false.
    lv_scan_idx = lv_first_idx + 1.

    WHILE lv_scan_idx <= lv_max AND lv_if_depth > 0.
      ls_stmt = zcl_skylint_ast_util=>get_statement( it_statements = is_procedure-statements
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
              report_statement( is_statement    = ls_first
                                iv_finding_code = c_finding_codes-guard_method ).
            ELSE.
              ls_after = zcl_skylint_ast_util=>get_next_statement( it_statements    = is_procedure-statements
                                                                   iv_current_index = lv_scan_idx ).
              IF lv_has_else = abap_false AND ls_after-keyword = 'ENDMETHOD'.
                report_statement( is_statement    = ls_first
                                  iv_finding_code = c_finding_codes-guard_method ).
              ENDIF.
            ENDIF.
            EXIT.
          ENDIF.
      ENDCASE.
      lv_scan_idx += 1.
    ENDWHILE.
  ENDMETHOD.
ENDCLASS.
