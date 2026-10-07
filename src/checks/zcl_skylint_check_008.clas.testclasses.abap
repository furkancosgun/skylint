CLASS ltcl_check_008 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_check FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_008 IMPLEMENTATION.
  METHOD test_check.
    DATA lt_source TYPE string_table.

    lt_source = VALUE #(
        ( `CLASS zcl_skylint_test_008 DEFINITION` )
        ( `  PUBLIC FINAL` )
        ( `  CREATE PUBLIC.` )
        ( `` )
        ( `  PUBLIC SECTION.` )
        ( `    METHODS test_001.` )
        ( `    METHODS test_002.` )
        ( `    METHODS test_003.` )
        ( `    METHODS test_004.` )
        ( `ENDCLASS.` )
        ( `` )
        ( `CLASS zcl_skylint_test_008 IMPLEMENTATION.` )
        ( `  METHOD test_001.` )
        ( `    DATA: lv_a TYPE i,` )
        ( `          lv_b TYPE i.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_002.` )
        ( `    DATA lv_a TYPE i.` )
        ( `    DATA lv_b TYPE i.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_003.` )
        ( `    CONSTANTS: c_one TYPE i VALUE 1,` )
        ( `               c_two TYPE i VALUE 2.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_004.` )
        ( `    CONSTANTS c_one TYPE i VALUE 1.` )
        ( `    CONSTANTS c_two TYPE i VALUE 2.` )
        ( `  ENDMETHOD.` )
        ( `ENDCLASS.` ) ).

    zcl_skylint_test_runner=>run(
        io_check    = NEW zcl_skylint_check_008( )
        it_source   = lt_source
        it_expected = VALUE #(
            ( method = 'TEST_001'
               code = zcl_skylint_check_008=>c_finding_codes-chained_declaration line = 3 column = 4 )
            ( method = 'TEST_002' )
            ( method = 'TEST_003'
               code = zcl_skylint_check_008=>c_finding_codes-chained_declaration line = 3 column = 4 )
            ( method = 'TEST_004' ) ) ).
  ENDMETHOD.
ENDCLASS.
