CLASS zcl_skylint_check_092 DEFINITION
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
    CONSTANTS c_pseudo_comment TYPE string VALUE 'GUARD_IN_METHOD'.
ENDCLASS.


CLASS zcl_skylint_check_092 IMPLEMENTATION.
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
    "TODO daha temiz yazılsın
    DATA lv_count TYPE i.
    DATA lv_idx TYPE i.
    DATA ls_last TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_first_exec TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_stmt TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA lv_last_found TYPE abap_bool.
    DATA lv_stmt_found TYPE abap_bool.
    DATA lv_has_first TYPE abap_bool.

    lv_count = lines( is_procedure-statements ).
    IF lv_count < 3.
      RETURN.
    ENDIF.

    " Check if last statement before ENDMETHOD is ENDIF
    get_statement_safe( EXPORTING it_statements = is_procedure-statements
                                  iv_index      = lv_count
                        IMPORTING es_statement  = ls_last
                                  ev_found      = lv_last_found ).
    IF lv_last_found = abap_false.
      RETURN.
    ENDIF.
    IF ls_last-keyword = 'ENDMETHOD' AND lv_count >= 2.
      get_statement_safe( EXPORTING it_statements = is_procedure-statements
                                    iv_index      = lv_count - 1
                          IMPORTING es_statement  = ls_last
                                    ev_found      = lv_last_found ).
      IF lv_last_found = abap_false.
        RETURN.
      ENDIF.
    ENDIF.

    IF ls_last-keyword <> 'ENDIF'.
      RETURN.
    ENDIF.

    " Find first executable statement (skip DATA, TYPES, CONSTANTS, FIELD-SYMBOLS)
    lv_idx = 1.
    lv_has_first = abap_false.
    WHILE lv_idx <= lv_count.
      get_statement_safe( EXPORTING it_statements = is_procedure-statements
                                    iv_index      = lv_idx
                          IMPORTING es_statement  = ls_stmt
                                    ev_found      = lv_stmt_found ).
      IF lv_stmt_found = abap_false.
        lv_idx += 1.
        CONTINUE.
      ENDIF.
      CASE ls_stmt-keyword.
        WHEN 'METHOD' OR 'DATA' OR 'TYPES' OR 'CONSTANTS' OR 'FIELD-SYMBOLS'.
          lv_idx += 1.
          CONTINUE.
        WHEN OTHERS.
          ls_first_exec = ls_stmt.
          lv_has_first = abap_true.
          EXIT.
      ENDCASE.
    ENDWHILE.

    IF lv_has_first = abap_true AND ls_first_exec-keyword = 'IF'.
      report_statement( is_statement    = ls_first_exec
                        iv_finding_code = c_finding_codes-guard_method ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
