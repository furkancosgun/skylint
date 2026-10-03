CLASS ltcl_check_073 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean   FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_073 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_073( )
        it_source   = VALUE #( ( `lv_x = lv_x + 1.` ) )
        it_expected = VALUE #( ( line = 2
                                 code = zcl_skylint_check_073=>c_finding_codes-calc_assign ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings( io_check  = NEW zcl_skylint_check_073( )
                                               it_source = VALUE #( ( `lv_x = 10.` ) ) ).
  ENDMETHOD.
ENDCLASS.
