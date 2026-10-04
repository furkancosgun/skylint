CLASS ltcl_check_079 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean   FOR TESTING RAISING cx_static_check.
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
    zcl_skylint_test_util=>assert_no_findings( io_check  = NEW zcl_skylint_check_079( )
                                               it_source = VALUE #( ( `METHODS meth IMPORTING iv_param TYPE i.` ) ) ).
  ENDMETHOD.
ENDCLASS.

*"* --- Local Test Fixture Class ---
CLASS lcl_test_code DEFINITION FINAL.
  PUBLIC SECTION.
    METHODS test_with_finding.
    METHODS test_clean_code.

  PRIVATE SECTION.
    METHODS meth_escaped IMPORTING !iv_param TYPE i.
    METHODS meth_clean IMPORTING iv_param TYPE i.
ENDCLASS.

CLASS lcl_test_code IMPLEMENTATION.
  METHOD test_with_finding.
    RETURN.
  ENDMETHOD.

  METHOD test_clean_code.
    RETURN.
  ENDMETHOD.

  METHOD meth_escaped.
    RETURN.
  ENDMETHOD.

  METHOD meth_clean.
    RETURN.
  ENDMETHOD.
ENDCLASS.
