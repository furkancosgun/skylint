CLASS ltcl_check_044 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean   FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_044 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_044( )
        it_source   = VALUE #( ( `SYNTAX-CHECK FOR lt_prog MESSAGE lv_msg LINE lv_lin WORD lv_wrd.` ) )
        it_expected = VALUE #( ( line = 2
                                 code = zcl_skylint_check_044=>c_finding_codes-dangerous_statement ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings( io_check  = NEW zcl_skylint_check_044( )
                                               it_source = VALUE #( ( `CHECK lv_flag = abap_true.` ) ) ).
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
    DATA lv_msg TYPE string.
    DATA lv_lin TYPE i.
    DATA lv_wrd TYPE string.
    DATA lt_prog TYPE string_table.
    SYNTAX-CHECK FOR lt_prog MESSAGE lv_msg LINE lv_lin WORD lv_wrd.
  ENDMETHOD.

  METHOD test_clean_code.
    DATA lv_flag TYPE abap_bool.
    CHECK lv_flag = abap_true.
  ENDMETHOD.
ENDCLASS.
