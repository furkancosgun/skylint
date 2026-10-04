CLASS ltcl_check_020 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean   FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_020 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_020( )
        it_source   = VALUE #( ( `IF 'X' = lv_code.` ) )
        it_expected = VALUE #( ( line = 2
                                 code = zcl_skylint_check_020=>c_finding_codes-yoda_condition ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings( io_check  = NEW zcl_skylint_check_020( )
                                               it_source = VALUE #( ( `IF lv_code = 'X'.` ) ) ).
  ENDMETHOD.
ENDCLASS.

*"* --- Local Test Fixture Class ---
CLASS lcl_test_code DEFINITION FINAL.
  PUBLIC SECTION.
    METHODS test_with_finding.
    METHODS test_clean_code.
ENDCLASS.

CLASS lcl_test_code IMPLEMENTATION.
  METHOD test_with_finding.
    DATA lv_code TYPE c LENGTH 1.
    IF 'X' = lv_code.
    ENDIF.
  ENDMETHOD.

  METHOD test_clean_code.
    DATA lv_code TYPE c LENGTH 1.
    IF lv_code = 'X'.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
