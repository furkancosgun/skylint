CLASS zcl_skylint_check_101 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        decl_order TYPE if_ci_atc_check=>ty_finding_code VALUE 'DECL_ORDER',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'LOCAL_DECL_ORDER'.
ENDCLASS.


CLASS zcl_skylint_check_101 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Enforce local declaration order (TYPES -> CONSTANTS -> DATA -> FIELD-SYMBOLS)'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-decl_order
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'Declare local TYPES before CONSTANTS before DATA before FIELD-SYMBOLS'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_max_rank TYPE i VALUE 0.
    DATA lv_curr_rank TYPE i.
    FIELD-SYMBOLS <ls_stmt> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_stmt>.
      lv_curr_rank = 0.
      CASE <ls_stmt>-keyword.
        WHEN 'TYPES'.
          lv_curr_rank = 1.
        WHEN 'CONSTANTS'.
          lv_curr_rank = 2.
        WHEN 'DATA'.
          lv_curr_rank = 3.
        WHEN 'FIELD-SYMBOLS'.
          lv_curr_rank = 4.
      ENDCASE.

      IF lv_curr_rank > 0.
        IF lv_curr_rank < lv_max_rank.
          report_statement( is_statement    = <ls_stmt>
                            iv_finding_code = c_finding_codes-decl_order ).
        ELSE.
          lv_max_rank = lv_curr_rank.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
