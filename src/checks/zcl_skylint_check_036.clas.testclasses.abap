CLASS ltcl_check_036 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean   FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_036 IMPLEMENTATION.
  METHOD test_finding.
    " RTTI-blocked: finding needs get_single_importing_param( ) on a real method,
    " but synthetic refs never resolve via describe_by_name, so the would-be
    " trigger below yields no finding in this harness.
    zcl_skylint_test_util=>assert_no_findings( io_check  = NEW zcl_skylint_check_036( )
                                               it_source = VALUE #( ( `lo_obj->run( iv_param = lv_val ).` ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings( io_check  = NEW zcl_skylint_check_036( )
                                               it_source = VALUE #( ( `lo_obj->run( lv_val ).` ) ) ).
  ENDMETHOD.
ENDCLASS.
