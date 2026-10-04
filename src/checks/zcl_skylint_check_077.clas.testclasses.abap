CLASS ltcl_check_077 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean   FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_077 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_077( )
        it_source   = VALUE #( ( `DATA lv_unused TYPE i.` ) )
        it_expected = VALUE #( ( line = 2
                                 code = zcl_skylint_check_077=>c_finding_codes-unused_var ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings( io_check  = NEW zcl_skylint_check_077( )
                                               it_source = VALUE #( ( `DATA lv_used TYPE i.` )
                                                                    ( `lv_used = 1.` ) ) ).
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
    DATA lv_unused TYPE i.
  ENDMETHOD.

  METHOD test_clean_code.
    DATA lv_used TYPE i.
    lv_used = 1.
  ENDMETHOD.
ENDCLASS.
