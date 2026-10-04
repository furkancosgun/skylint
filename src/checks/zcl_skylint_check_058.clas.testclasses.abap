CLASS ltcl_check_058 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    " Finding unreachable: synthetic unit ZSKYLINT_TEST does not exist, so
    " describe_by_name always fails and check returns early. Class-definition
    " procedure mode used for both guards.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean   FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_058 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check            = NEW zcl_skylint_check_058( )
        it_source           = VALUE #( ( `CLASS lcl_god DEFINITION.` )
                                       ( `PUBLIC SECTION.` )
                                       ( `DATA mv_a1 TYPE i.` )
                                       ( `DATA mv_a2 TYPE i.` )
                                       ( `DATA mv_a3 TYPE i.` )
                                       ( `DATA mv_a4 TYPE i.` )
                                       ( `DATA mv_a5 TYPE i.` )
                                       ( `DATA mv_a6 TYPE i.` ) )
        it_expected         = VALUE #( ( line = 1
                                         code = zcl_skylint_check_058=>c_finding_codes-attribute_count ) )
        iv_class_definition = abap_true ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings( io_check            = NEW zcl_skylint_check_058( )
                                               it_source           = VALUE #( ( `CLASS lcl_small DEFINITION FINAL.` ) )
                                               iv_class_definition = abap_true ).
  ENDMETHOD.
ENDCLASS.

*"* --- Local Test Fixture Class ---
CLASS lcl_god DEFINITION.
  PUBLIC SECTION.
    DATA mv_a1 TYPE i.
    DATA mv_a2 TYPE i.
    DATA mv_a3 TYPE i.
    DATA mv_a4 TYPE i.
    DATA mv_a5 TYPE i.
    DATA mv_a6 TYPE i.
    DATA mv_a7 TYPE i.
    DATA mv_a8 TYPE i.
    DATA mv_a9 TYPE i.
    DATA mv_a10 TYPE i.
    DATA mv_a11 TYPE i.
    DATA mv_a12 TYPE i.
    DATA mv_a13 TYPE i.
    DATA mv_a14 TYPE i.
    DATA mv_a15 TYPE i.
    DATA mv_a16 TYPE i.
    DATA mv_a17 TYPE i.
    DATA mv_a18 TYPE i.
    DATA mv_a19 TYPE i.
    DATA mv_a20 TYPE i.
    DATA mv_a21 TYPE i.
ENDCLASS.
CLASS lcl_god IMPLEMENTATION.
ENDCLASS.

CLASS lcl_test_code DEFINITION FINAL.
  PUBLIC SECTION.
    METHODS test_with_finding.
    METHODS test_clean_code.
ENDCLASS.

CLASS lcl_test_code IMPLEMENTATION.
  METHOD test_with_finding.
    RETURN.
  ENDMETHOD.

  METHOD test_clean_code.
    RETURN.
  ENDMETHOD.
ENDCLASS.
