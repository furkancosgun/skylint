CLASS ltcl_check_078 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean   FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_078 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_078( )
        it_source   = VALUE #( ( `DATA lv_x TYPE i.` )
                               ( `TYPES ty_t TYPE i.` ) )
        it_expected = VALUE #( ( line = 3
                                 code = zcl_skylint_check_078=>c_finding_codes-decl_order ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings( io_check  = NEW zcl_skylint_check_078( )
                                               it_source = VALUE #( ( `TYPES ty_t TYPE i.` )
                                                                    ( `DATA lv_x TYPE i.` ) ) ).
  ENDMETHOD.
ENDCLASS.

*"* --- Local Test Fixture Class ---
CLASS lcl_test_code DEFINITION FINAL.
  PUBLIC SECTION.
    METHODS test_with_finding.
    METHODS test_clean_code.
ENDCLASS.


CLASS lcl_test_code IMPLEMENTATION.
  METHOD test_with_finding.
    DATA lv_x TYPE i.
    TYPES ty_t TYPE i.
  ENDMETHOD.

  METHOD test_clean_code.
    TYPES ty_t TYPE i.
    DATA lv_x TYPE i.
  ENDMETHOD.
ENDCLASS.
