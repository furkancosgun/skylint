CLASS ltcl_check_008 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding  FOR TESTING RAISING cx_static_check.
    METHODS test_clean    FOR TESTING RAISING cx_static_check.
    METHODS test_fixed    FOR TESTING RAISING cx_static_check.
    METHODS test_quickfix FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_008 IMPLEMENTATION.
  METHOD test_finding.
    DATA lo_check TYPE REF TO zcl_skylint_check_008.

    lo_check = NEW #( ).
    zcl_skylint_test_util=>assert_findings(
        io_check    = lo_check
        it_source   = VALUE #( ( `DATA: lv_a TYPE i,` )
                               ( `      lv_b TYPE i.` ) )
        it_expected = VALUE #( ( line = 2
                                 code = zcl_skylint_check_008=>c_finding_codes-chained_declaration ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings( io_check  = NEW zcl_skylint_check_008( )
                                               it_source = VALUE #( ( `DATA lv_a TYPE i.` )
                                                                    ( `DATA lv_b TYPE i.` ) ) ).
  ENDMETHOD.

  METHOD test_fixed.
    zcl_skylint_test_util=>assert_fixed( io_check        = NEW zcl_skylint_check_008( )
                                         it_fixed_source = VALUE #( ( `DATA lv_a TYPE i.` )
                                                                    ( `DATA lv_b TYPE i.` ) ) ).
  ENDMETHOD.

  METHOD test_quickfix.
    zcl_skylint_test_util=>assert_quickfix( io_check          = NEW zcl_skylint_check_008( )
                                            it_bad_source     = VALUE #( ( `DATA: lv_a TYPE i,` )
                                                                         ( `      lv_b TYPE i.` ) )
                                            it_expected_fixed = VALUE #( ( `DATA lv_a TYPE i.` )
                                                                         ( `DATA lv_b TYPE i.` ) )
                                            iv_quickfix_code  = zcl_skylint_check_008=>c_quickfix_codes-resolve_chain ).
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
    DATA: lv_a TYPE i,
          lv_b TYPE i.
  ENDMETHOD.

  METHOD test_clean_code.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
  ENDMETHOD.
ENDCLASS.
