CLASS ltcl_check_004 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_004 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_004( )
        it_source   = VALUE #( ( `IF NOT lv_x IS INITIAL.` ) )
        it_expected = VALUE #( ( line = 2
                                 code = zcl_skylint_check_004=>c_finding_codes-prefer_is_not ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings(
        io_check  = NEW zcl_skylint_check_004( )
        it_source = VALUE #( ( `IF lv_x IS NOT INITIAL.` ) ) ).
  ENDMETHOD.
ENDCLASS.

*"* --- Local Test Fixture Class ---
CLASS lcl_test_code DEFINITION FINAL.
  PUBLIC SECTION.
    METHODS test_with_finding.
    METHODS test_clean_code.
ENDCLASS.

CLASS lcl_test_code IMPLEMENTATION.
  METHOD test_with_finding.
    DATA lv_x TYPE i.
    IF NOT lv_x IS INITIAL.
    ENDIF.
  ENDMETHOD.

  METHOD test_clean_code.
    DATA lv_x TYPE i.
    IF lv_x IS NOT INITIAL.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
