CLASS zcl_skylint_check_001 DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        test_seam TYPE if_ci_atc_check=>ty_finding_code VALUE 'TESTSEAMUS',
      END OF c_finding_codes.

    METHODS constructor.

  PROTECTED SECTION.
    METHODS check REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'TEST_SEAM_USAGE'.

ENDCLASS.


CLASS zcl_skylint_check_001 IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
        VALUE #( description       = 'Usage of TEST-SEAM'
                 remote_enablement = abap_true
                 finding_codes     = VALUE #( ( code           = c_finding_codes-test_seam
                                                severity       = if_ci_atc_check=>finding_severities-warning
                                                text           = 'Usage of TEST-SEAM'
                                                pseudo_comment = c_pseudo_comment ) ) ) ).
  ENDMETHOD.

  METHOD check.
    FIELD-SYMBOLS <ls_statement> TYPE if_ci_atc_source_code_provider=>ty_statement.

    LOOP AT is_procedure-statements ASSIGNING <ls_statement>
         WHERE keyword = 'TEST-SEAM'.
      report_statement( is_statement    = <ls_statement>
                        iv_finding_code = c_finding_codes-test_seam ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
