CLASS ltcl_check_068 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean   FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_068 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_068( )
        it_source   = VALUE #( ( `LOOP AT lt_tab INTO ls_row.` )
                               ( `MODIFY lt_tab FROM ls_row.` )
                               ( `ENDLOOP.` ) )
        it_expected = VALUE #( ( line = 3
                                 code = zcl_skylint_check_068=>c_finding_codes-full_modify ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings( io_check  = NEW zcl_skylint_check_068( )
                                               it_source = VALUE #( ( `LOOP AT lt_tab INTO ls_row.` )
                                                                    ( `MODIFY lt_tab FROM ls_row TRANSPORTING field1.` )
                                                                    ( `ENDLOOP.` ) ) ).
  ENDMETHOD.
ENDCLASS.

*"* --- Local Test Fixture Class ---
CLASS lcl_test_code DEFINITION FINAL.
  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_row,
        field1 TYPE i,
      END OF ty_row.

    METHODS test_with_finding.
    METHODS test_clean_code.
ENDCLASS.

CLASS lcl_test_code IMPLEMENTATION.
  METHOD test_with_finding.
    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.
    DATA ls_row TYPE ty_row.
    LOOP AT lt_tab INTO ls_row.
      MODIFY lt_tab FROM ls_row.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_clean_code.
    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.
    DATA ls_row TYPE ty_row.
    LOOP AT lt_tab INTO ls_row.
      MODIFY lt_tab FROM ls_row TRANSPORTING field1.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
