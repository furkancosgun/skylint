CLASS ltcl_check_031 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_031 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_031( )
        it_source   = VALUE #( ( `SELECT * FROM t INTO TABLE r FOR ALL ENTRIES IN s WHERE f = s-f.` ) )
        it_expected = VALUE #( ( line = 2
                                 code = zcl_skylint_check_031=>c_finding_codes-unsecure_fae ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings(
        io_check  = NEW zcl_skylint_check_031( )
        it_source = VALUE #( ( `IF s IS NOT INITIAL.` )
                             ( `SELECT * FROM t INTO TABLE r FOR ALL ENTRIES IN s WHERE f = s-f.` )
                             ( `ENDIF.` ) ) ).
  ENDMETHOD.
ENDCLASS.
