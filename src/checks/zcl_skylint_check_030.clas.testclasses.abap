CLASS ltcl_check_030 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_030 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_030( )
        it_source   = VALUE #( ( `LOOP AT lt_tab INTO ls_row.` )
                               ( `SELECT SINGLE * FROM t001 INTO @ls_row WHERE field = @ls_key.` )
                               ( `ENDLOOP.` ) )
        it_expected = VALUE #( ( line = 3
                                 code = zcl_skylint_check_030=>c_finding_codes-db_in_loop ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings(
        io_check  = NEW zcl_skylint_check_030( )
        it_source = VALUE #( ( `SELECT SINGLE * FROM t001 INTO @ls_row WHERE field = @ls_key.` ) ) ).
  ENDMETHOD.
ENDCLASS.
