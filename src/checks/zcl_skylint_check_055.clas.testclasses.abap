CLASS ltcl_check_055 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    " Finding unreachable: synthetic unit ZSKYLINT_TEST does not exist, so
    " describe_by_name always fails and check returns early. Class-definition
    " procedure mode used for both guards.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean   FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_055 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check            = NEW zcl_skylint_check_055( )
        it_source           = VALUE #( ( `CLASS lcl_helper DEFINITION.` )
                                       ( `PUBLIC SECTION.` )
                                       ( `CLASS-METHODS run.` )
                                       ( `ENDCLASS.` ) )
        it_expected         = VALUE #( ( line = 1
                                         code = zcl_skylint_check_055=>c_finding_codes-static_class ) )
        iv_class_definition = abap_true ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings( io_check            = NEW zcl_skylint_check_055( )
                                               it_source           = VALUE #( ( `CLASS lcl_helper DEFINITION.` )
                                                                              ( `PUBLIC SECTION.` )
                                                                              ( `CLASS-METHODS run.` )
                                                                              ( `METHODS execute.` )
                                                                              ( `ENDCLASS.` ) )
                                               iv_class_definition = abap_true ).
  ENDMETHOD.
ENDCLASS.

*"* --- Local Test Fixture Class ---
CLASS lcl_helper DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS run.
ENDCLASS.
CLASS lcl_helper IMPLEMENTATION.
  METHOD run.
    RETURN.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_clean DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS run.
    METHODS execute.
ENDCLASS.
CLASS lcl_clean IMPLEMENTATION.
  METHOD run.
    RETURN.
  ENDMETHOD.
  METHOD execute.
    RETURN.
  ENDMETHOD.
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
