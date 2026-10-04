CLASS ltcl_check_010 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean   FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_010 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_010( )
        it_source   = VALUE #( ( `IF is_valid( ) = abap_true.` ) )
        it_expected = VALUE #( ( line = 2
                                 code = zcl_skylint_check_010=>c_finding_codes-bool_comparison ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings(
        io_check  = NEW zcl_skylint_check_010( )
        it_source = VALUE #( ( `IF is_valid( ).` )
                             ( `IF lv_flag = abap_true.` )
                             ( `IF lv_flag = abap_false.` ) ) ).
  ENDMETHOD.
ENDCLASS.
