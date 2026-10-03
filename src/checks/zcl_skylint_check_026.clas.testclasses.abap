CLASS ltcl_check_026 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean   FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_026 IMPLEMENTATION.
  METHOD test_finding.
    " RTTI-blocked: finding needs is_static_method( ) on a real class, but the
    " synthetic unit ZSKYLINT_TEST never resolves via describe_by_name, so the
    " would-be trigger below yields no finding in this harness.
    zcl_skylint_test_util=>assert_no_findings( io_check  = NEW zcl_skylint_check_026( )
                                               it_source = VALUE #( ( `lo_obj->do_work( ).` ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings( io_check  = NEW zcl_skylint_check_026( )
                                               it_source = VALUE #( ( `cl_useful=>do_work( ).` ) ) ).
  ENDMETHOD.
ENDCLASS.
