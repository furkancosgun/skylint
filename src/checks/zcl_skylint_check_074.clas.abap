CLASS zcl_skylint_check_074 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        guard_loop TYPE if_ci_atc_check=>ty_finding_code VALUE 'GUARD_LOOP',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'GUARD_IN_LOOP'.
ENDCLASS.


CLASS zcl_skylint_check_074 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Use early CONTINUE guard clause instead of wrapping loop in IF block'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-guard_loop
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Invert IF condition and use CONTINUE to reduce nesting in loop'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    "TODO daha temiz yazilsin
    DATA lv_idx TYPE i.
    DATA lv_count TYPE i.
    DATA lv_prev_idx TYPE i.
    DATA ls_stmt TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_next TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_if TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA ls_cand TYPE if_ci_atc_source_code_provider=>ty_statement.
    DATA lv_stmt_found TYPE abap_bool.
    DATA lv_next_found TYPE abap_bool.
    DATA lv_if_found TYPE abap_bool.
    DATA lv_cand_found TYPE abap_bool.

    lv_count = lines( is_procedure-statements ).
    lv_idx = 1.

    WHILE lv_idx < lv_count.
      get_statement_safe( EXPORTING it_statements = is_procedure-statements
                                    iv_index      = lv_idx
                          IMPORTING es_statement  = ls_stmt
                                    ev_found      = lv_stmt_found ).
      get_statement_safe( EXPORTING it_statements = is_procedure-statements
                                    iv_index      = lv_idx + 1
                          IMPORTING es_statement  = ls_next
                                    ev_found      = lv_next_found ).
      IF lv_stmt_found = abap_false OR lv_next_found = abap_false.
        lv_idx += 1.
        CONTINUE.
      ENDIF.
      IF ls_stmt-keyword <> 'ENDIF' OR ls_next-keyword <> 'ENDLOOP'.
        lv_idx += 1.
        CONTINUE.
      ENDIF.
      lv_prev_idx = lv_idx - 1.
      WHILE lv_prev_idx > 1.
        get_statement_safe( EXPORTING it_statements = is_procedure-statements
                                      iv_index      = lv_prev_idx
                            IMPORTING es_statement  = ls_if
                                      ev_found      = lv_if_found ).
        IF lv_if_found = abap_false.
          lv_prev_idx -= 1.
          CONTINUE.
        ENDIF.
        CASE ls_if-keyword.
          WHEN 'LOOP'.
            EXIT.
          WHEN 'IF'.
            get_statement_safe( EXPORTING it_statements = is_procedure-statements
                                          iv_index      = lv_prev_idx - 1
                                IMPORTING es_statement  = ls_cand
                                          ev_found      = lv_cand_found ).
            IF lv_cand_found = abap_true AND ls_cand-keyword = 'LOOP'.
              report_statement( is_statement    = ls_if
                                iv_finding_code = c_finding_codes-guard_loop ).
            ENDIF.
            EXIT.
          WHEN OTHERS.
            lv_prev_idx -= 1.
        ENDCASE.
      ENDWHILE.
      lv_idx += 1.
    ENDWHILE.
  ENDMETHOD.
ENDCLASS.
