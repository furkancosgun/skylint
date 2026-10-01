CLASS ltcl_check_022 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_022 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_022( )
        it_source   = VALUE #( ( `CREATE OBJECT lo_obj.` ) )
        it_expected = VALUE #( ( line = 2
                                 code = zcl_skylint_check_022=>c_finding_codes-prefer_new ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings(
        io_check  = NEW zcl_skylint_check_022( )
        it_source = VALUE #( ( `CREATE OBJECT lo_obj TYPE (lv_cls).` ) ) ).
  ENDMETHOD.
ENDCLASS.
