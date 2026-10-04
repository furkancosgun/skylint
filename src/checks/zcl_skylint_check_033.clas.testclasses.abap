CLASS ltcl_check_033 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean   FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_033 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_033( )
        it_source   = VALUE #( ( `IF lv_flag = abap_true.` )
                               ( `DATA lv_inner TYPE i.` )
                               ( `ENDIF.` )
                               ( `lv_inner = 1.` ) )
        it_expected = VALUE #( ( line = 5
                                 code = zcl_skylint_check_033=>c_finding_codes-scope_leak ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings( io_check  = NEW zcl_skylint_check_033( )
                                               it_source = VALUE #( ( `DATA lv_val TYPE i.` )
                                                                    ( `lv_val = 1.` ) ) ).
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
    DATA lv_flag TYPE abap_bool.
    IF lv_flag = abap_true.
    DATA lv_inner TYPE i.
    ENDIF.
    lv_inner = 1.
  ENDMETHOD.

  METHOD test_clean_code.
    DATA lv_val TYPE i.
    lv_val = 1.
  ENDMETHOD.
ENDCLASS.
