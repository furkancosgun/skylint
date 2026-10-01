CLASS ltcl_check_008 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    " Finding unreachable in this harness: the mini-lexer unrolls chains but
    " stamps every continuation with the header keyword, so
    " `should_report_chain` always exits early on `is_next-keyword IS NOT
    " INITIAL`. Guard only; real ATC driver needed for coverage.
    METHODS test_guard_no_false_positive FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_008 IMPLEMENTATION.
  METHOD test_guard_no_false_positive.
    zcl_skylint_test_util=>assert_no_findings(
        io_check  = NEW zcl_skylint_check_008( )
        it_source = VALUE #( ( `DATA: lv_a TYPE i, lv_b TYPE i.` ) ) ).
  ENDMETHOD.
ENDCLASS.
