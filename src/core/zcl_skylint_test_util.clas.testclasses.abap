CLASS ltcl_test_util DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS describe_finding FOR TESTING RAISING cx_static_check.
    METHODS describe_clean FOR TESTING RAISING cx_static_check.
    METHODS quickfix_roundtrip FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_test_util IMPLEMENTATION.
  METHOD describe_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_001( )
        it_source   = VALUE #( ( `DESCRIBE TABLE lt_tab LINES lv_cnt.` ) )
        it_expected = VALUE #( ( line = 2
                                 code = zcl_skylint_check_001=>c_finding_codes-describe_lines ) ) ).
  ENDMETHOD.

  METHOD describe_clean.
    zcl_skylint_test_util=>assert_no_findings(
        io_check  = NEW zcl_skylint_check_001( )
        it_source = VALUE #( ( `lv_cnt = lines( lt_tab ).` ) ) ).
  ENDMETHOD.

  METHOD quickfix_roundtrip.
    DATA lo_check TYPE REF TO zcl_skylint_check_006.

    lo_check = NEW #( ).
    zcl_skylint_test_util=>assert_findings(
        io_check    = lo_check
        it_source   = VALUE #( ( `lo_obj->run( EXPORTING iv_in = lv_x ).` ) )
        it_expected = VALUE #( ( line = 2
                                 code = zcl_skylint_check_006=>c_finding_codes-omit_exporting ) ) ).

    zcl_skylint_test_util=>assert_fixed(
        io_check        = lo_check
        it_fixed_source = VALUE #( ( `lo_obj->run( iv_in = lv_x ).` ) ) ).
  ENDMETHOD.
ENDCLASS.
