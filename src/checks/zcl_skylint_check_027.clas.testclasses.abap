CLASS ltcl_check_027 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean   FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_027 IMPLEMENTATION.
  METHOD test_finding.
    " RTTI-blocked (DECL check): finding needs describe_by_name( main_unit ), but
    " the synthetic unit ZSKYLINT_TEST never resolves, so no finding is reachable.
    zcl_skylint_test_util=>assert_no_findings(
        io_check            = NEW zcl_skylint_check_027( )
        it_source           = VALUE #( ( `CLASS zcl_test DEFINITION PUBLIC CREATE PUBLIC.` )
                                       ( `PUBLIC SECTION.` )
                                       ( `DATA mv_attr TYPE i.` )
                                       ( `ENDCLASS.` ) )
        iv_class_definition = abap_true ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings(
        io_check            = NEW zcl_skylint_check_027( )
        it_source           = VALUE #( ( `CLASS zcl_test DEFINITION PUBLIC CREATE PUBLIC.` )
                                       ( `PUBLIC SECTION.` )
                                       ( `DATA mv_attr TYPE i READ-ONLY.` )
                                       ( `ENDCLASS.` ) )
        iv_class_definition = abap_true ).
  ENDMETHOD.
ENDCLASS.
