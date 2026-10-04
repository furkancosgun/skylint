CLASS ltcl_check_023 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean   FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_023 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_023( )
        it_source   = VALUE #( ( `RAISE EXCEPTION TYPE cx_static_check.` ) )
        it_expected = VALUE #( ( line = 2
                                 code = zcl_skylint_check_023=>c_finding_codes-raise_exception_new ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings( io_check  = NEW zcl_skylint_check_023( )
                                               it_source = VALUE #( ( `RAISE EXCEPTION NEW cx_static_check( ).` ) ) ).
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
    RAISE EXCEPTION TYPE cx_sy_zerodivide.
  ENDMETHOD.

  METHOD test_clean_code.
    RAISE EXCEPTION NEW cx_sy_zerodivide( ).
  ENDMETHOD.
ENDCLASS.
