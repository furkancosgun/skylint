CLASS ltcl_check_003 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean   FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_003 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_003( )
        it_source   = VALUE #( ( `DATA lt_tab TYPE STANDARD TABLE OF i WITH DEFAULT KEY.` ) )
        it_expected = VALUE #( ( line = 2
                                 code = zcl_skylint_check_003=>c_finding_codes-default_key ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings(
        io_check  = NEW zcl_skylint_check_003( )
        it_source = VALUE #( ( `DATA lt_tab TYPE STANDARD TABLE OF i WITH EMPTY KEY.` ) ) ).
  ENDMETHOD.
ENDCLASS.
