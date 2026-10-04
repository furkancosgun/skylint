CLASS ltcl_check_075 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean   FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_075 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_075( )
        it_source   = VALUE #( ( `IF lv_flag = abap_true.` )
                               ( `ls_val = 1.` )
                               ( `ENDIF.` ) )
        it_expected = VALUE #( ( line = 2
                                 code = zcl_skylint_check_075=>c_finding_codes-guard_method ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings( io_check  = NEW zcl_skylint_check_075( )
                                               it_source = VALUE #( ( `IF lv_flag = abap_true.` )
                                                                    ( `ls_val = 1.` )
                                                                    ( `ELSE.` )
                                                                    ( `ls_val = 2.` )
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
    DATA lv_flag TYPE abap_bool.
    DATA ls_val TYPE i.
    IF lv_flag = abap_true.
    ls_val = 1.
    ENDIF.
  ENDMETHOD.

  METHOD test_clean_code.
    DATA lv_flag TYPE abap_bool.
    DATA ls_val TYPE i.
    IF lv_flag = abap_true.
    ls_val = 1.
    ELSE.
    ls_val = 2.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
