CLASS ltcl_check_060 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean FOR TESTING RAISING cx_static_check.
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
    zcl_skylint_test_util=>assert_no_findings(
        io_check  = NEW zcl_skylint_check_060( )
        it_source = VALUE #( ( `CATCH cx_static_check.` ) ) ).
  ENDMETHOD.
ENDCLASS.
