CLASS ltcl_check_029 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean   FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_029 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check            = NEW zcl_skylint_check_029( )
        it_source           = VALUE #( ( `METHODS run IMPORTING a TYPE i b TYPE i c TYPE i d TYPE i` )
                                       ( `e TYPE i f TYPE i g TYPE i h TYPE i j TYPE i.` ) )
        it_expected         = VALUE #( ( line = 1
                                         code = zcl_skylint_check_029=>c_finding_codes-too_many_parameters ) )
        iv_class_definition = abap_true ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings(
        io_check            = NEW zcl_skylint_check_029( )
        it_source           = VALUE #( ( `METHODS run IMPORTING a TYPE i b TYPE i.` ) )
        iv_class_definition = abap_true ).
  ENDMETHOD.
ENDCLASS.
