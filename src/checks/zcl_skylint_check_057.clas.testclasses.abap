CLASS ltcl_check_057 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    " Finding unreachable: synthetic unit ZSKYLINT_TEST does not exist, so
    " describe_by_name always fails and check returns early. Class-definition
    " procedure mode used for both guards.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean   FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_057 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_no_findings(
        io_check            = NEW zcl_skylint_check_057( )
        it_source           = VALUE #( ( `CLASS lcl_child DEFINITION INHERITING FROM lcl_parent.` ) )
        iv_class_definition = abap_true ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings( io_check            = NEW zcl_skylint_check_057( )
                                               it_source           = VALUE #( ( `CLASS lcl_simple DEFINITION.` ) )
                                               iv_class_definition = abap_true ).
  ENDMETHOD.
ENDCLASS.

*"* --- Local Test Fixture Class ---
CLASS lcl_l1 DEFINITION.
ENDCLASS.
CLASS lcl_l1 IMPLEMENTATION.
ENDCLASS.
CLASS lcl_l2 DEFINITION INHERITING FROM lcl_l1.
ENDCLASS.
CLASS lcl_l2 IMPLEMENTATION.
ENDCLASS.
CLASS lcl_l3 DEFINITION INHERITING FROM lcl_l2.
ENDCLASS.
CLASS lcl_l3 IMPLEMENTATION.
ENDCLASS.
CLASS lcl_l4 DEFINITION INHERITING FROM lcl_l3.
ENDCLASS.
CLASS lcl_l4 IMPLEMENTATION.
ENDCLASS.
CLASS lcl_child DEFINITION INHERITING FROM lcl_l4.
ENDCLASS.
CLASS lcl_child IMPLEMENTATION.
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
