CLASS ltcl_check_072 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean   FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_072 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_072( )
        it_source   = VALUE #( ( `CONDENSE lv_text.` )
                               ( `TRANSLATE lv_text TO UPPER CASE.` ) )
        it_expected = VALUE #( ( line = 2
                                 code = zcl_skylint_check_072=>c_finding_codes-condense_stmt )
                               ( line = 3
                                 code = zcl_skylint_check_072=>c_finding_codes-translate_stmt ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings( io_check  = NEW zcl_skylint_check_072( )
                                               it_source = VALUE #( ( `lv_text = condense( lv_text ).` )
                                                                    ( `lv_text = to_upper( lv_text ).` ) ) ).
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
    DATA lv_text TYPE string.
    CONDENSE lv_text.
    TRANSLATE lv_text TO UPPER CASE.
  ENDMETHOD.

  METHOD test_clean_code.
    DATA lv_text TYPE string.
    lv_text = condense( lv_text ).
    lv_text = to_upper( lv_text ).
  ENDMETHOD.
ENDCLASS.
