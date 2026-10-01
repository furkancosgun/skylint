CLASS ltcl_check_021 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_021 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_021( )
        it_source   = VALUE #( ( `IF lv_a EQ lv_b.` )
                               ( `ENDIF.` ) )
        it_expected = VALUE #( ( line = 2
                                 code = zcl_skylint_check_021=>c_finding_codes-prefer_operator ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings(
        io_check  = NEW zcl_skylint_check_021( )
        it_source = VALUE #( ( `IF lv_a = lv_b.` )
                             ( `ENDIF.` ) ) ).
  ENDMETHOD.
ENDCLASS.
