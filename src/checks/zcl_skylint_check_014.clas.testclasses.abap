CLASS ltcl_check_014 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_014 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_014( )
        it_source   = VALUE #( ( `IF lv_x = 1.` )
                               ( `ENDIF.` ) )
        it_expected = VALUE #( ( line = 2
                                 code = zcl_skylint_check_014=>c_finding_codes-empty_control_block ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings(
        io_check  = NEW zcl_skylint_check_014( )
        it_source = VALUE #( ( `IF lv_x = 1.` )
                             ( `lv_x = 2.` )
                             ( `ENDIF.` ) ) ).
  ENDMETHOD.
ENDCLASS.
