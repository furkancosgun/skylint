CLASS zcl_skylint_check_096 DEFINITION
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


CLASS zcl_skylint_check_096 IMPLEMENTATION.
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
    DATA lv_idx TYPE i.
    DATA lv_count TYPE i.
    DATA lv_prev_idx TYPE i.
    FIELD-SYMBOLS <ls_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_next> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_if> TYPE if_ci_atc_source_code_provider=>ty_statement.

    lv_count = lines( is_procedure-statements ).
    lv_idx = 1.

    WHILE lv_idx < lv_count.
      ASSIGN is_procedure-statements[ lv_idx ] TO <ls_stmt>.
      ASSIGN is_procedure-statements[ lv_idx + 1 ] TO <ls_next>.

      IF <ls_stmt>-keyword = 'ENDIF' AND <ls_next>-keyword = 'ENDLOOP'.
        lv_prev_idx = lv_idx - 1.
        WHILE lv_prev_idx > 1.
          ASSIGN is_procedure-statements[ lv_prev_idx ] TO <ls_if>.
          IF <ls_if>-keyword = 'LOOP'.
            EXIT.
          ENDIF.
          IF <ls_if>-keyword = 'IF'.
            ASSIGN is_procedure-statements[ lv_prev_idx - 1 ] TO <ls_next>.
            IF sy-subrc = 0 AND <ls_next>-keyword = 'LOOP'.
              report_statement( is_statement    = <ls_if>
                                iv_finding_code = c_finding_codes-guard_loop ).
            ENDIF.
            EXIT.
          ENDIF.
          lv_prev_idx = lv_prev_idx - 1.
        ENDWHILE.
      ENDIF.
      lv_idx = lv_idx + 1.
    ENDWHILE.
  ENDMETHOD.
ENDCLASS.
