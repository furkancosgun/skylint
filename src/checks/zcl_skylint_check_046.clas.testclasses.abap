CLASS ltcl_check_046 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean   FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_046 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_046( )
        it_source   = VALUE #( ( `SELECT * FROM mara UP TO 1 ROWS INTO TABLE lt_mara.` ) )
        it_expected = VALUE #( ( line = 2
                                 code = zcl_skylint_check_046=>c_finding_codes-missing_order_by ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings(
        io_check  = NEW zcl_skylint_check_046( )
        it_source = VALUE #( ( `SELECT * FROM mara UP TO 1 ROWS INTO TABLE lt_mara ORDER BY matnr.` ) ) ).
  ENDMETHOD.
ENDCLASS.
