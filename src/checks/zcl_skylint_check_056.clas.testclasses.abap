CLASS ltcl_check_056 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    " Finding unreachable: synthetic unit ZSKYLINT_TEST does not exist, so
    " describe_by_name always fails and check returns early. Class-definition
    " procedure mode used for both guards.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean   FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_056 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check            = NEW zcl_skylint_check_056( )
        it_source           = VALUE #( ( `METHODS get_status RETURNING VALUE(rv_flag) TYPE abap_bool.` ) )
        it_expected         = VALUE #( ( line = 1
                                         code = zcl_skylint_check_056=>c_finding_codes-bool_method_name ) )
        iv_class_definition = abap_true ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings(
        io_check            = NEW zcl_skylint_check_056( )
        it_source           = VALUE #( ( `METHODS is_valid RETURNING VALUE(rv_flag) TYPE abap_bool.` ) )
        iv_class_definition = abap_true ).
  ENDMETHOD.
ENDCLASS.

*"* --- Local Test Fixture Class ---
CLASS lcl_test_code DEFINITION FINAL.
  PUBLIC SECTION.
    METHODS test_with_finding.
    METHODS test_clean_code.

  PRIVATE SECTION.
    METHODS get_status RETURNING VALUE(rv_flag) TYPE abap_bool.
    METHODS is_valid RETURNING VALUE(rv_flag) TYPE abap_bool.
ENDCLASS.

CLASS lcl_test_code IMPLEMENTATION.
  METHOD test_with_finding.
    RETURN.
  ENDMETHOD.

  METHOD test_clean_code.
    RETURN.
  ENDMETHOD.

  METHOD get_status.
    rv_flag = abap_true.
  ENDMETHOD.

  METHOD is_valid.
    rv_flag = abap_true.
  ENDMETHOD.
ENDCLASS.
