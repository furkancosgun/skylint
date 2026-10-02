CLASS zcl_skylint_check_062 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        nested_try TYPE zif_skylint_types=>ty_finding_code VALUE 'NESTED_TRY',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'AVOID_NESTED_TRY'.
ENDCLASS.


CLASS zcl_skylint_check_062 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Avoid nested TRY blocks; extract inner error handling to helper methods'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #( ( code           = c_finding_codes-nested_try
                                                severity       = zif_skylint_types=>severities-warning
                                                text           = 'Avoid nested TRY blocks; extract to dedicated method'
                                                pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA lv_try_depth TYPE i VALUE 0.
    FIELD-SYMBOLS <ls_statement> TYPE zif_skylint_types=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>.
      CASE <ls_statement>-keyword.
        WHEN 'TRY'.
          IF lv_try_depth >= 1.
            report_statement( is_statement    = <ls_statement>
                              iv_finding_code = c_finding_codes-nested_try ).
          ENDIF.
          lv_try_depth = lv_try_depth + 1.

        WHEN 'ENDTRY'.
          IF lv_try_depth > 0.
            lv_try_depth = lv_try_depth - 1.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
