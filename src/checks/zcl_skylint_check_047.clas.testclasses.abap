CLASS ltcl_check_047 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    " Finding is reported on the first procedure statement (METHOD test.),
    " hence expected line = 1. Five IFs give complexity 6 > default max 5.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_047 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_047( )
        it_source   = VALUE #( ( `IF lv_a = 1.` )
                               ( `ENDIF.` )
                               ( `IF lv_b = 2.` )
                               ( `ENDIF.` )
                               ( `IF lv_c = 3.` )
                               ( `ENDIF.` )
                               ( `IF lv_d = 4.` )
                               ( `ENDIF.` )
                               ( `IF lv_e = 5.` )
                               ( `ENDIF.` ) )
        it_expected = VALUE #( ( line = 1
                                 code = zcl_skylint_check_047=>c_finding_codes-cyclomatic_complexity ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings(
        io_check  = NEW zcl_skylint_check_047( )
        it_source = VALUE #( ( `IF lv_a = 1.` )
                             ( `ENDIF.` ) ) ).
  ENDMETHOD.
ENDCLASS.
