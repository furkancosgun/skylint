CLASS ltcl_check_039 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean   FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_039 IMPLEMENTATION.
  METHOD test_finding.
    " Finding is reported on the first procedure statement (the METHOD wrapper).
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_039( )
        it_source   = VALUE #( ( `lv_a = 1.` )
                               ( `lv_b = 2.` )
                               ( `lv_c = 3.` )
                               ( `lv_d = 4.` )
                               ( `lv_e = 5.` )
                               ( `lv_f = 6.` ) )
        it_expected = VALUE #( ( line = 1
                                 code = zcl_skylint_check_039=>c_finding_codes-method_length ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings( io_check  = NEW zcl_skylint_check_039( )
                                               it_source = VALUE #( ( `lv_a = 1.` )
                                                                    ( `lv_b = 2.` ) ) ).
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
    DATA lv_f TYPE i.
    lv_a = 1.
    lv_b = 2.
    lv_c = 3.
    lv_d = 4.
    lv_e = 5.
    lv_f = 6.
  ENDMETHOD.

  METHOD test_clean_code.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    lv_a = 1.
    lv_b = 2.
  ENDMETHOD.
ENDCLASS.
