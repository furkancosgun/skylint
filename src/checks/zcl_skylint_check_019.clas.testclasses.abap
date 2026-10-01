CLASS ltcl_check_019 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_019 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_019( )
        it_source   = VALUE #( ( `CASE lv_type.` )
                               ( `WHEN 1.` )
                               ( `lv_x = 1.` )
                               ( `ENDCASE.` ) )
        it_expected = VALUE #( ( line = 2
                                 code = zcl_skylint_check_019=>c_finding_codes-short_case ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings(
        io_check  = NEW zcl_skylint_check_019( )
        it_source = VALUE #( ( `CASE lv_type.` )
                             ( `WHEN 1.` )
                             ( `lv_x = 1.` )
                             ( `WHEN 2.` )
                             ( `lv_x = 2.` )
                             ( `ENDCASE.` ) ) ).
  ENDMETHOD.
ENDCLASS.
