CLASS ltcl_check_060 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean   FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_060 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_060( )
        it_source   = VALUE #( ( `CATCH cx_root.` ) )
        it_expected = VALUE #( ( line = 2
                                 code = zcl_skylint_check_060=>c_finding_codes-catch_root ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings( io_check  = NEW zcl_skylint_check_060( )
                                               it_source = VALUE #( ( `CATCH cx_static_check.` ) ) ).
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
    TRY.
    CATCH cx_root.
    ENDTRY.
  ENDMETHOD.

  METHOD test_clean_code.
    TRY.
    CATCH cx_static_check.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
