CLASS ltcl_check_069 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean   FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_069 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_069( )
        it_source   = VALUE #( ( `METHODS bad_name FOR TESTING.` ) )
        it_expected = VALUE #( ( line = 2
                                 code = zcl_skylint_check_069=>c_finding_codes-test_name ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings( io_check  = NEW zcl_skylint_check_069( )
                                               it_source = VALUE #( ( `METHODS test_something FOR TESTING.` ) ) ).
  ENDMETHOD.
ENDCLASS.

*"* --- Local Test Fixture Class ---
CLASS lcl_test_naming DEFINITION FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    METHODS bad_name FOR TESTING.
    METHODS test_clean FOR TESTING.
ENDCLASS.

CLASS lcl_test_naming IMPLEMENTATION.
  METHOD bad_name.
    RETURN.
  ENDMETHOD.

  METHOD test_clean.
    RETURN.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_test_code DEFINITION FINAL.
  PUBLIC SECTION.
    METHODS test_with_finding.
    METHODS test_clean_code.
ENDCLASS.

CLASS lcl_test_code IMPLEMENTATION.
  METHOD test_with_finding.
    RETURN.
  ENDMETHOD.

  METHOD test_clean_code.
    RETURN.
  ENDMETHOD.
ENDCLASS.
