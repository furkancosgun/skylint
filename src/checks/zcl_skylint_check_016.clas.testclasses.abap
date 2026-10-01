CLASS ltcl_check_016 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_016 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_016( )
        it_source   = VALUE #( ( `IF lv_a = 1.` )
                               ( `lv_b = 2.` )
                               ( `ELSEIF lv_a = 1.` )
                               ( `lv_c = 3.` )
                               ( `ENDIF.` ) )
        it_expected = VALUE #( ( line = 4
                                 code = zcl_skylint_check_016=>c_finding_codes-identical_condition ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings(
        io_check  = NEW zcl_skylint_check_016( )
        it_source = VALUE #( ( `IF lv_a = 1.` )
                             ( `lv_b = 2.` )
                             ( `ELSEIF lv_a = 2.` )
                             ( `lv_c = 3.` )
                             ( `ENDIF.` ) ) ).
  ENDMETHOD.
ENDCLASS.
