CLASS ltcl_check_061 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_061 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_061( )
        it_source   = VALUE #( ( `MESSAGE ID 'Z1' TYPE 'E' RAISING cx_static_check.` ) )
        it_expected = VALUE #( ( line = 2
                                 code = zcl_skylint_check_061=>c_finding_codes-msg_raise ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings(
        io_check  = NEW zcl_skylint_check_061( )
        it_source = VALUE #( ( `MESSAGE ID 'Z1' TYPE 'E'.` ) ) ).
  ENDMETHOD.
ENDCLASS.
