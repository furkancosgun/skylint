CLASS ltcl_check_059 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    " Finding unreachable: synthetic unit ZSKYLINT_TEST does not exist, so
    " describe_by_name always fails and check returns early. Class-definition
    " procedure mode used for both guards.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean   FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_059 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check            = NEW zcl_skylint_check_059( )
        it_source           = VALUE #( ( `INTERFACE lif_test PUBLIC.` )
                                       ( `DATA mv_state TYPE i.` ) )
        it_expected         = VALUE #( ( line = 2
                                         code = zcl_skylint_check_059=>c_finding_codes-interface_data ) )
        iv_class_definition = abap_true ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings(
        io_check            = NEW zcl_skylint_check_059( )
        it_source           = VALUE #( ( `INTERFACE lif_clean PUBLIC.` )
                                       ( `CONSTANTS c_version TYPE i VALUE 1.` ) )
        iv_class_definition = abap_true ).
  ENDMETHOD.
ENDCLASS.

*"* --- Local Test Fixture Class ---
INTERFACE lif_test.
  DATA mv_state TYPE i.
ENDINTERFACE.

INTERFACE lif_clean.
  CONSTANTS c_version TYPE i VALUE 1.
ENDINTERFACE.

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
