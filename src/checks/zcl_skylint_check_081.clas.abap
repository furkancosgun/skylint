CLASS zcl_skylint_check_081 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        missing_cleanup TYPE if_ci_atc_check=>ty_finding_code VALUE 'TRY_CLEAN',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'MISSING_CLEANUP'.
ENDCLASS.


CLASS zcl_skylint_check_081 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Ensure TRY blocks handling resources include a CLEANUP section'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #(
                     ( code           = c_finding_codes-missing_cleanup
                       severity       = if_ci_atc_check=>finding_severities-warning
                       text           = 'TRY block handling resources is missing a CLEANUP section'
                       pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_in_try TYPE abap_bool VALUE abap_false.
    DATA lv_has_cleanup TYPE abap_bool VALUE abap_false.
    DATA ls_try_stmt TYPE if_ci_atc_source_code_provider=>ty_statement.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'TRY'.
          lv_in_try = abap_true.
          lv_has_cleanup = abap_false.
          ls_try_stmt = <ls_statement>.

        WHEN 'CLEANUP'.
          lv_has_cleanup = abap_true.

        WHEN 'ENDTRY'.
          IF lv_in_try = abap_true AND lv_has_cleanup = abap_false.
            report_statement( is_statement    = ls_try_stmt
                              iv_finding_code = c_finding_codes-missing_cleanup ).
          ENDIF.
          lv_in_try = abap_false.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
