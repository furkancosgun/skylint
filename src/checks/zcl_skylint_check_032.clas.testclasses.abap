CLASS ltcl_check_032 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean   FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_032 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_032( )
        it_source   = VALUE #( ( `SELECT * FROM t001 INTO @DATA(ls_row).` )
                               ( `ENDSELECT.` ) )
        it_expected = VALUE #( ( line = 2
                                 code = zcl_skylint_check_032=>c_finding_codes-select_star )
                               ( line = 3
                                 code = zcl_skylint_check_032=>c_finding_codes-select_endselect ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings(
        io_check  = NEW zcl_skylint_check_032( )
        it_source = VALUE #( ( `SELECT field1 FROM t001 INTO TABLE lt_tab.` ) ) ).
  ENDMETHOD.
ENDCLASS.
