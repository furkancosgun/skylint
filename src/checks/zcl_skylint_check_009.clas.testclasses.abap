CLASS ltcl_check_009 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_009 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_009( )
        it_source   = VALUE #( ( `CONCATENATE lv_a lv_b INTO lv_c.` ) )
        it_expected = VALUE #( ( line = 2
                                 code = zcl_skylint_check_009=>c_finding_codes-prefer_template ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings(
        io_check  = NEW zcl_skylint_check_009( )
        it_source = VALUE #( ( `lv_c = |{ lv_a }{ lv_b }|.` ) ) ).
  ENDMETHOD.
ENDCLASS.
