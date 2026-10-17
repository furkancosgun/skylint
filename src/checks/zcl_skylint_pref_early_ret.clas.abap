CLASS zcl_skylint_pref_early_ret DEFINITION
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

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'EARLY_RETURN'.

    METHODS get_first_executable_stmt
      IMPORTING it_statements TYPE if_ci_atc_source_code_provider=>ty_statements
      EXPORTING ev_index      TYPE i
                es_statement  TYPE if_ci_atc_source_code_provider=>ty_statement.

    METHODS if_wraps_method_end
      IMPORTING it_statements TYPE if_ci_atc_source_code_provider=>ty_statements
                iv_if_idx     TYPE i
      RETURNING VALUE(rv_yes) TYPE abap_bool.
ENDCLASS.


CLASS zcl_skylint_pref_early_ret IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Use early RETURN guard clause instead of wrapping method in IF block'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-guard_method
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Invert IF condition and use RETURN to reduce nesting in method'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_first_idx  TYPE i.
    DATA ls_first_stmt TYPE if_ci_atc_source_code_provider=>ty_statement.

    get_first_executable_stmt( EXPORTING it_statements = is_procedure-statements
                               IMPORTING ev_index      = lv_first_idx
                                         es_statement  = ls_first_stmt ).

    IF ls_first_stmt-keyword <> 'IF' OR lv_first_idx = 0.
      RETURN.
    ENDIF.

    IF if_wraps_method_end( it_statements = is_procedure-statements
                            iv_if_idx     = lv_first_idx ) = abap_true.
      report_statement( is_statement    = ls_first_stmt
                        iv_finding_code = c_finding_codes-guard_method ).
    ENDIF.
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
ENDCLASS.
