CLASS ltcl_check_079 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_079 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_079( )
        it_source   = VALUE #( ( `METHODS meth IMPORTING !iv_param TYPE i.` ) )
        it_expected = VALUE #( ( line = 2
                                 code = zcl_skylint_check_079=>c_finding_codes-param_escape ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings(
        io_check  = NEW zcl_skylint_check_079( )
        it_source = VALUE #( ( `METHODS meth IMPORTING iv_param TYPE i.` ) ) ).
  ENDMETHOD.
ENDCLASS.
