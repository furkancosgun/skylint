CLASS ltcl_check_048 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_check FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_048 IMPLEMENTATION.
  METHOD test_check.
    DATA lt_source TYPE string_table.

    lt_source = VALUE #(
        ( `CLASS lcl_not_final DEFINITION.` )
        ( `ENDCLASS.` )
        ( `CLASS lcl_not_final IMPLEMENTATION.` )
        ( `ENDCLASS.` )
        ( `` )
        ( `CLASS lcl_clean DEFINITION FINAL.` )
        ( `ENDCLASS.` )
        ( `CLASS lcl_clean IMPLEMENTATION.` )
        ( `ENDCLASS.` )
        ( `` )
        ( `CLASS lcl_child2 DEFINITION INHERITING FROM lcl_not_final.` )
        ( `ENDCLASS.` )
        ( `CLASS lcl_child2 IMPLEMENTATION.` )
        ( `ENDCLASS.` )
        ( `` )
        ( `CLASS lcl_clean2 DEFINITION FINAL INHERITING FROM lcl_not_final.` )
        ( `ENDCLASS.` )
        ( `CLASS lcl_clean2 IMPLEMENTATION.` )
        ( `ENDCLASS.` )
        ( `` )
        ( `CLASS zcl_skylint_test_048 DEFINITION` )
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
        ( `CLASS zcl_skylint_test_048 IMPLEMENTATION.` )
        ( `  METHOD test_001.` )
        ( `    RETURN.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_002.` )
        ( `    RETURN.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_003.` )
        ( `    RETURN.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_004.` )
        ( `    DATA lv_val TYPE i.` )
        ( `    lv_val = 1.` )
        ( `  ENDMETHOD.` )
        ( `ENDCLASS.` ) ).

    zcl_skylint_test_runner=>run(
        io_check    = NEW zcl_skylint_check_048( )
        it_source   = lt_source
        it_expected = VALUE #(
            ( method = 'TEST_001' code = zcl_skylint_check_048=>c_finding_codes-class_not_final line = 1 column = 0 )
            ( method = 'TEST_002' )
            ( method = 'TEST_003' code = zcl_skylint_check_048=>c_finding_codes-class_not_final line = 1 column = 0 )
            ( method = 'TEST_004' ) ) ).
  ENDMETHOD.
ENDCLASS.
