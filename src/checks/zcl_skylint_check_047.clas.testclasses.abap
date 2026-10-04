CLASS ltcl_check_047 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    " Finding is reported on the first procedure statement (METHOD test.),
    " hence expected line = 1. Five IFs give complexity 6 > default max 5.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean   FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_047 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_047( )
        it_source   = VALUE #( ( `IF lv_a = 1.` )
                               ( `ENDIF.` )
                               ( `IF lv_b = 2.` )
                               ( `ENDIF.` )
                               ( `IF lv_c = 3.` )
                               ( `ENDIF.` )
                               ( `IF lv_d = 4.` )
                               ( `ENDIF.` )
                               ( `IF lv_e = 5.` )
                               ( `ENDIF.` ) )
        it_expected = VALUE #( ( line = 1
                                 code = zcl_skylint_check_047=>c_finding_codes-cyclomatic_complexity ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings( io_check  = NEW zcl_skylint_check_047( )
                                               it_source = VALUE #( ( `IF lv_a = 1.` )
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
    DATA lv_d TYPE i.
    DATA lv_e TYPE i.
    IF lv_a = 1.
    ENDIF.
    IF lv_b = 2.
    ENDIF.
    IF lv_c = 3.
    ENDIF.
    IF lv_d = 4.
    ENDIF.
    IF lv_e = 5.
    ENDIF.
  ENDMETHOD.

  METHOD test_clean_code.
    DATA lv_a TYPE i.
    IF lv_a = 1.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
