CLASS ltcl_check_012 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_012 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_012( )
        it_source   = VALUE #( ( `EXIT.` ) )
        it_expected = VALUE #( ( line = 2
                                 code = zcl_skylint_check_012=>c_finding_codes-exit_outside_loop ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings(
        io_check  = NEW zcl_skylint_check_012( )
        it_source = VALUE #( ( `LOOP AT lt_tab INTO ls_row.` )
                             ( `EXIT.` )
                             ( `ENDLOOP.` ) ) ).
  ENDMETHOD.
ENDCLASS.
