CLASS zcl_skylint_check_100 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        needless_clear TYPE if_ci_atc_check=>ty_finding_code VALUE 'NEEDLES_CL',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'NEEDLESS_CLEAR'.
ENDCLASS.


CLASS zcl_skylint_check_100 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Detect needless CLEAR on newly declared variable or before exit'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-needless_clear
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Variables are initialized automatically; avoid CLEAR after DATA or before exit'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_idx      TYPE i.
    DATA lv_count    TYPE i.
    DATA lv_var_name TYPE string.
    FIELD-SYMBOLS <ls_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_prev> TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_next> TYPE if_ci_atc_source_code_provider=>ty_statement.

    lv_count = lines( is_procedure-statements ).
    lv_idx = 1.

    WHILE lv_idx <= lv_count.
      ASSIGN is_procedure-statements[ lv_idx ] TO <ls_stmt>.

      IF <ls_stmt>-keyword = 'CLEAR' AND lines( <ls_stmt>-tokens ) >= 2.
        lv_var_name = to_upper( <ls_stmt>-tokens[ 2 ]-lexeme ).

        " Case 1: Immediately after DATA declaration
        IF lv_idx > 1.
          ASSIGN is_procedure-statements[ lv_idx - 1 ] TO <ls_prev>.
          IF <ls_prev>-keyword = 'DATA' AND lines( <ls_prev>-tokens ) >= 2.
            IF to_upper( <ls_prev>-tokens[ 2 ]-lexeme ) = lv_var_name.
              report_statement( is_statement    = <ls_stmt>
                                iv_finding_code = c_finding_codes-needless_clear ).
              lv_idx += 1.
              CONTINUE.
            ENDIF.
          ENDIF.
        ENDIF.

        " Case 2: Immediately before ENDMETHOD
        IF lv_idx < lv_count.
          ASSIGN is_procedure-statements[ lv_idx + 1 ] TO <ls_next>.
          IF <ls_next>-keyword = 'ENDMETHOD'.
            report_statement( is_statement    = <ls_stmt>
                              iv_finding_code = c_finding_codes-needless_clear ).
          ENDIF.
        ENDIF.
      ENDIF.

      lv_idx += 1.
    ENDWHILE.
  ENDMETHOD.
ENDCLASS.
