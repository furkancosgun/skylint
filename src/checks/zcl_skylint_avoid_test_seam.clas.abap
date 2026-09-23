CLASS zcl_skylint_avoid_test_seam DEFINITION
  PUBLIC
  INHERITING FROM zcl_skylint_check_base
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS:
      BEGIN OF c_finding_codes,
        test_seam TYPE if_ci_atc_check=>ty_finding_code VALUE 'TESTSEAMUS',
      END OF c_finding_codes.

  PROTECTED SECTION.
    METHODS describe REDEFINITION.
    METHODS check    REDEFINITION.

  PRIVATE SECTION.
    CONSTANTS c_pseudo_comment TYPE string VALUE 'TEST_SEAM_USAGE'.

ENDCLASS.


CLASS zcl_skylint_avoid_test_seam IMPLEMENTATION.
  METHOD describe.
    rs_result = VALUE #( description       = 'Usage of TEST-SEAM'
                         remote_enablement = abap_true
                         finding_codes     = VALUE #( ( code           = c_finding_codes-test_seam
                                                        severity       = if_ci_atc_check=>finding_severities-warning
                                                        text           = 'Usage of TEST-SEAM'
                                                        pseudo_comment = c_pseudo_comment ) ) ).
  ENDMETHOD.

  METHOD check.
    DATA(lo_stream) = get_token_stream( is_procedure ).
    DATA(lt_matches) = lo_stream->find_statements_by_keyword( 'TEST-SEAM' ).

    LOOP AT lt_matches ASSIGNING FIELD-SYMBOL(<ls_statement>).
      get_reporter( )->report_statement( is_statement    = <ls_statement>
                                         iv_finding_code = c_finding_codes-test_seam ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
