CLASS ltcl_check_029 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_029 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check            = NEW zcl_skylint_check_029( )
        it_source           = VALUE #( ( `METHODS run IMPORTING iv_1 TYPE i iv_2 TYPE i iv_3 TYPE i iv_4 TYPE i iv_5 TYPE i iv_6 TYPE i iv_7 TYPE i iv_8 TYPE i iv_9 TYPE i.` ) )
        it_expected         = VALUE #( ( line = 1
                                         code = zcl_skylint_check_029=>c_finding_codes-too_many_parameters ) )
        iv_class_definition = abap_true ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings(
        io_check            = NEW zcl_skylint_check_029( )
        it_source           = VALUE #( ( `METHODS run IMPORTING iv_1 TYPE i iv_2 TYPE i.` ) )
        iv_class_definition = abap_true ).
  ENDMETHOD.
ENDCLASS.
