CLASS ltcl_check_013 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean   FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_013 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_013( )
        it_source   = VALUE #( ( `LOOP AT lt_tab INTO ls_row.` )
                               ( `CHECK lv_flag.` )
                               ( `ENDLOOP.` ) )
        it_expected = VALUE #( ( line = 3
                                 code = zcl_skylint_check_013=>c_finding_codes-check_in_loop ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings( io_check  = NEW zcl_skylint_check_013( )
                                               it_source = VALUE #( ( `CHECK lv_flag.` ) ) ).
  ENDMETHOD.
ENDCLASS.
