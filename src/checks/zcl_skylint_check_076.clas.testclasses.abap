CLASS ltcl_check_076 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_076 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_076( )
        it_source   = VALUE #( ( `ASSERT lv_x > 0.` ) )
        it_expected = VALUE #( ( line = 2
                                 code = zcl_skylint_check_076=>c_finding_codes-prod_assert ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings(
        io_check  = NEW zcl_skylint_check_076( )
        it_source = VALUE #( ( `IF lv_x IS INITIAL.` )
                             ( `ENDIF.` ) ) ).
  ENDMETHOD.
ENDCLASS.
