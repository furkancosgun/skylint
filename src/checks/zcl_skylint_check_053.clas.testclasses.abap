CLASS ltcl_check_053 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_053 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_053( )
        it_source   = VALUE #( ( `DATA lv_x LIKE mara-matnr.` ) )
        it_expected = VALUE #( ( line = 2
                                 code = zcl_skylint_check_053=>c_finding_codes-avoid_like ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings(
        io_check  = NEW zcl_skylint_check_053( )
        it_source = VALUE #( ( `DATA lv_x TYPE mara-matnr.` ) ) ).
  ENDMETHOD.
ENDCLASS.
