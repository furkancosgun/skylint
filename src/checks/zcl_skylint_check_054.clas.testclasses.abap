CLASS ltcl_check_054 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_check FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_054 IMPLEMENTATION.
  METHOD test_check.
    DATA lt_source TYPE string_table.

    lt_source = VALUE #(
        ( `CLASS zcl_skylint_test_054 DEFINITION` )
        ( `  PUBLIC FINAL` )
        ( `  CREATE PUBLIC.` )
        ( `` )
        ( `  PUBLIC SECTION.` )
        ( `    METHODS constructor.` )
        ( `    METHODS test_001.` )
        ( `    METHODS test_002.` )
        ( `    METHODS test_003.` )
        ( `    METHODS test_004.` )
        ( `ENDCLASS.` )
        ( `` )
        ( `CLASS zcl_skylint_test_054 IMPLEMENTATION.` )
        ( `  METHOD constructor.` )
        ( `    DATA lv_val TYPE i.` )
        ( `    lv_val = 1.` )
        ( `    lv_val = 1.` )
        ( `    lv_val = 1.` )
        ( `    lv_val = 1.` )
        ( `    lv_val = 1.` )
        ( `    lv_val = 1.` )
        ( `    lv_val = 1.` )
        ( `    lv_val = 1.` )
        ( `    lv_val = 1.` )
        ( `    lv_val = 1.` )
        ( `    lv_val = 1.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_001.` )
        ( `    RETURN.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_002.` )
        ( `    RETURN.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_003.` )
        ( `    DATA lv_a TYPE i.` )
        ( `    DATA lv_b TYPE i.` )
        ( `    lv_a = 1.` )
        ( `    lv_b = 2.` )
        ( `    lv_a = 3.` )
        ( `    lv_b = 4.` )
        ( `    lv_a = 5.` )
        ( `    lv_b = 6.` )
        ( `    lv_a = 7.` )
        ( `    lv_b = 8.` )
        ( `    lv_a = 9.` )
        ( `    lv_b = 10.` )
        ( `    lv_a = 11.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_004.` )
        ( `    DATA lv_a TYPE i.` )
        ( `    lv_a = 1.` )
        ( `  ENDMETHOD.` )
        ( `ENDCLASS.` ) ).

    zcl_skylint_test_runner=>run(
        io_check    = NEW zcl_skylint_check_054( )
        it_source   = lt_source
        it_expected = VALUE #( ( method = 'TEST_001' )
                               ( method = 'TEST_002' )
                               ( method = 'TEST_003' )
                               ( method = 'TEST_004' )
                               ( method = 'CONSTRUCTOR'
               code = zcl_skylint_check_054=>c_finding_codes-constructor_logic line = 12 column = 4 ) ) ).
  ENDMETHOD.
ENDCLASS.
