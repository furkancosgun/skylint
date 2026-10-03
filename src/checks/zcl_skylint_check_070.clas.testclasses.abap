CLASS ltcl_check_070 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean   FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_070 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_070( )
        it_source   = VALUE #( ( `SELECT * FROM (lv_tab) INTO TABLE lt_tab.` ) )
        it_expected = VALUE #( ( line = 2
                                 code = zcl_skylint_check_070=>c_finding_codes-dyn_sql ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings( io_check  = NEW zcl_skylint_check_070( )
                                               it_source = VALUE #( ( `SELECT * FROM t001 INTO TABLE lt_tab.` ) ) ).
  ENDMETHOD.
ENDCLASS.
