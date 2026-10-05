CLASS ltcl_check_006 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding  FOR TESTING RAISING cx_static_check.
    METHODS test_clean    FOR TESTING RAISING cx_static_check.
    METHODS test_quickfix FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_006 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_006( )
        it_source   = VALUE #( ( `lo_obj->run( EXPORTING iv_in = lv_x ).` ) )
        it_expected = VALUE #( ( line = 2
                                 code = zcl_skylint_check_006=>c_finding_codes-omit_exporting ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings( io_check  = NEW zcl_skylint_check_006( )
                                               it_source = VALUE #( ( `lo_obj->run( iv_in = lv_x ).` ) ) ).
  ENDMETHOD.

  METHOD test_quickfix.
    zcl_skylint_test_util=>assert_quickfix(
        io_check          = NEW zcl_skylint_check_006( )
        it_bad_source     = VALUE #( ( `lo_obj->run( EXPORTING iv_in = lv_x ).` ) )
        it_expected_fixed = VALUE #( ( `lo_obj->run( iv_in = lv_x ).` ) )
        iv_quickfix_code  = zcl_skylint_check_006=>c_quickfix_codes-omit_exporting ).
  ENDMETHOD.
ENDCLASS.
