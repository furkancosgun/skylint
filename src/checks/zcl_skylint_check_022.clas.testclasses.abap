CLASS ltcl_check_022 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean   FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_022 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_022( )
        it_source   = VALUE #( ( `CREATE OBJECT lo_obj.` ) )
        it_expected = VALUE #( ( line = 2
                                 code = zcl_skylint_check_022=>c_finding_codes-prefer_new ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings( io_check  = NEW zcl_skylint_check_022( )
                                               it_source = VALUE #( ( `CREATE OBJECT lo_obj TYPE (lv_cls).` ) ) ).
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
    DATA lo_obj TYPE REF TO lcl_test_code.
    CREATE OBJECT lo_obj.
  ENDMETHOD.

  METHOD test_clean_code.
    DATA lo_obj TYPE REF TO lcl_test_code.
    DATA lv_cls TYPE string.
    CREATE OBJECT lo_obj TYPE (lv_cls).
  ENDMETHOD.
ENDCLASS.
