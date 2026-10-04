CLASS ltcl_check_017 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean   FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_017 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_017( )
        it_source   = VALUE #( ( `IF lv_a = 1.` )
                               ( `IF lv_b = 2.` )
                               ( `lv_c = 3.` )
                               ( `ENDIF.` )
                               ( `ENDIF.` ) )
        it_expected = VALUE #( ( line = 2
                                 code = zcl_skylint_check_017=>c_finding_codes-nested_if ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings( io_check  = NEW zcl_skylint_check_017( )
                                               it_source = VALUE #( ( `IF lv_a = 1.` )
                                                                    ( `lv_b = 2.` )
                                                                    ( `ENDIF.` ) ) ).
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
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_c TYPE i.
    IF lv_a = 1.
    IF lv_b = 2.
    lv_c = 3.
    ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD test_clean_code.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    IF lv_a = 1.
    lv_b = 2.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
