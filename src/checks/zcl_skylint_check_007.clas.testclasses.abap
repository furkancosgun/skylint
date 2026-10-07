CLASS ltcl_check_007 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_check FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_007 IMPLEMENTATION.
  METHOD test_check.
    DATA lt_source TYPE string_table.

    lt_source = VALUE #(
        ( `CLASS zcl_skylint_test_007 DEFINITION` )
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
        ( `` )
        ( `CLASS zcl_skylint_test_007 IMPLEMENTATION.` )
        ( `  METHOD test_001.` )
        ( `    DATA lv_a TYPE i.` )
        ( `    DATA lv_b TYPE i.` )
        ( `    DATA lv_c TYPE i.` )
        ( `    lv_a = lv_b = lv_c.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_002.` )
        ( `    DATA lv_a TYPE i.` )
        ( `    DATA lv_b TYPE i.` )
        ( `    lv_a = lv_b.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_003.` )
        ( `    DATA lv_x TYPE i.` )
        ( `    DATA lv_y TYPE i.` )
        ( `    lv_x = lv_y = 10.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_004.` )
        ( `    DATA lv_x TYPE i.` )
        ( `    DATA lv_y TYPE i.` )
        ( `    lv_x = lv_y + 1.` )
        ( `  ENDMETHOD.` )
        ( `ENDCLASS.` )
        ( `` ) ).

    zcl_skylint_test_runner=>run(
        io_check    = NEW zcl_skylint_check_007( )
        it_source   = lt_source
        it_expected = VALUE #( ( method = 'TEST_001'
                               code = zcl_skylint_check_007=>c_finding_codes-assignment_chaining line = 5 column = 4 )
                               ( method = 'TEST_002' )
                               ( method = 'TEST_003'
               code = zcl_skylint_check_007=>c_finding_codes-assignment_chaining line = 4 column = 4 )
                               ( method = 'TEST_004' ) ) ).
  ENDMETHOD.
ENDCLASS.
