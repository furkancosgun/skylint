CLASS ltcl_check_042 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    " Finding unreachable: synthetic unit ZSKYLINT_TEST does not exist, so
    " describe_by_name always fails and check returns early. Class-definition
    " procedure mode used for both guards.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean   FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_042 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check            = NEW zcl_skylint_check_042( )
        it_source           = VALUE #( ( `METHODS get_value EXPORTING ev_val TYPE i.` ) )
        it_expected         = VALUE #( ( line = 1
                                         code = zcl_skylint_check_042=>c_finding_codes-prefer_returning ) )
        iv_class_definition = abap_true ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings(
        io_check            = NEW zcl_skylint_check_042( )
        it_source           = VALUE #( ( `METHODS get_value RETURNING VALUE(rv_val) TYPE i.` ) )
        iv_class_definition = abap_true ).
  ENDMETHOD.
ENDCLASS.

*"* --- Local Test Fixture Class ---
CLASS lcl_test_code DEFINITION FINAL.
  PUBLIC SECTION.
    METHODS test_with_finding.
    METHODS test_clean_code.

  PRIVATE SECTION.
    METHODS get_value_exporting EXPORTING ev_val TYPE i.
    METHODS get_value_returning RETURNING VALUE(rv_val) TYPE i.
ENDCLASS.

CLASS lcl_test_code IMPLEMENTATION.
  METHOD test_with_finding.
    RETURN.
  ENDMETHOD.

  METHOD test_clean_code.
    RETURN.
  ENDMETHOD.

  METHOD get_value_exporting.
    RETURN.
  ENDMETHOD.

  METHOD get_value_returning.
    RETURN.
  ENDMETHOD.
ENDCLASS.
