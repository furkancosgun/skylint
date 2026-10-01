CLASS ltcl_check_067 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    " Finding unreachable: synthetic unit ZSKYLINT_TEST never matches behavior
    " naming patterns nor RTTI supers, so is_behavior_implementation is false.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_067 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_no_findings(
        io_check  = NEW zcl_skylint_check_067( )
        it_source = VALUE #( ( `COMMIT WORK.` ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings(
        io_check  = NEW zcl_skylint_check_067( )
        it_source = VALUE #( ( `RETURN.` ) ) ).
  ENDMETHOD.
ENDCLASS.
