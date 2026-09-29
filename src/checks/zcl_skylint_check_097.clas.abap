CLASS zcl_skylint_check_097 DEFINITION
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


CLASS zcl_skylint_check_097 IMPLEMENTATION.
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
    DATA lv_count TYPE i.
    DATA lv_idx TYPE i.
    FIELD-SYMBOLS <ls_last> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_first_exec> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.

    lv_count = lines( is_procedure-statements ).
    IF lv_count < 3.
      RETURN.
    ENDIF.

    " Check if last statement before ENDMETHOD is ENDIF
    ASSIGN is_procedure-statements[ lv_count ] TO <ls_last>.
    IF <ls_last>-keyword = 'ENDMETHOD' AND lv_count >= 2.
      ASSIGN is_procedure-statements[ lv_count - 1 ] TO <ls_last>.
    ENDIF.

    IF <ls_last>-keyword <> 'ENDIF'.
      RETURN.
    ENDIF.

    " Find first executable statement (skip DATA, TYPES, CONSTANTS, FIELD-SYMBOLS)
    lv_idx = 1.
    WHILE lv_idx <= lv_count.
      ASSIGN is_procedure-statements[ lv_idx ] TO <ls_stmt>.
      IF <ls_stmt>-keyword <> 'METHOD'
          AND <ls_stmt>-keyword <> 'DATA'
          AND <ls_stmt>-keyword <> 'TYPES'
          AND <ls_stmt>-keyword <> 'CONSTANTS'
          AND <ls_stmt>-keyword <> 'FIELD-SYMBOLS'.
        ASSIGN <ls_stmt> TO <ls_first_exec>.
        EXIT.
      ENDIF.
      lv_idx = lv_idx + 1.
    ENDWHILE.

    IF <ls_first_exec> IS ASSIGNED AND <ls_first_exec>-keyword = 'IF'.
      report_statement( is_statement    = <ls_first_exec>
                        iv_finding_code = c_finding_codes-guard_method ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
