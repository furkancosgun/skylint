CLASS ltcl_check_051 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean   FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_051 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_051( )
        it_source   = VALUE #( ( `APPEND ls_row TO lt_tab.` ) )
        it_expected = VALUE #( ( line = 2
                                 code = zcl_skylint_check_051=>c_finding_codes-prefer_insert ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings( io_check  = NEW zcl_skylint_check_051( )
                                               it_source = VALUE #( ( `INSERT ls_row INTO TABLE lt_tab.` ) ) ).
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
    DATA lt_tab TYPE string_table.
    DATA ls_row TYPE string.
    APPEND ls_row TO lt_tab.
  ENDMETHOD.

  METHOD test_clean_code.
    DATA lt_tab TYPE string_table.
    DATA ls_row TYPE string.
    INSERT ls_row INTO TABLE lt_tab.
  ENDMETHOD.
ENDCLASS.
