CLASS ltcl_check_049 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean   FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_049 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_049( )
        it_source   = VALUE #( ( `RAISE SHORTDUMP TYPE cx_demo.` ) )
        it_expected = VALUE #( ( line = 2
                                 code = zcl_skylint_check_049=>c_finding_codes-raise_shortdump ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings( io_check  = NEW zcl_skylint_check_049( )
                                               it_source = VALUE #( ( `RAISE EXCEPTION TYPE cx_demo.` ) ) ).
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
    RAISE SHORTDUMP TYPE cx_sy_zerodivide.
  ENDMETHOD.

  METHOD test_clean_code.
    RAISE EXCEPTION TYPE cx_sy_zerodivide.
  ENDMETHOD.
ENDCLASS.
