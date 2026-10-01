CLASS ltcl_check_011 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_011 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_011( )
        it_source   = VALUE #( ( `READ TABLE lt_tab TRANSPORTING NO FIELDS.` ) )
        it_expected = VALUE #( ( line = 2
                                 code = zcl_skylint_check_011=>c_finding_codes-prefer_line_exists ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings(
        io_check  = NEW zcl_skylint_check_011( )
        it_source = VALUE #( ( `READ TABLE lt_tab INTO ls_row INDEX 1.` ) ) ).
  ENDMETHOD.
ENDCLASS.
