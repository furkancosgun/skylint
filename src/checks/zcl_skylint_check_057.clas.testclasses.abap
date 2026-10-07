CLASS ltcl_check_057 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_check FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_057 IMPLEMENTATION.
  METHOD test_check.
    DATA lt_source TYPE string_table.

    lt_source = VALUE #(
        ( `CLASS lcl_l1 DEFINITION.` )
        ( `ENDCLASS.` )
        ( `CLASS lcl_l1 IMPLEMENTATION.` )
        ( `ENDCLASS.` )
        ( `CLASS lcl_l2 DEFINITION INHERITING FROM lcl_l1.` )
        ( `ENDCLASS.` )
        ( `CLASS lcl_l2 IMPLEMENTATION.` )
        ( `ENDCLASS.` )
        ( `CLASS lcl_l3 DEFINITION INHERITING FROM lcl_l2.` )
        ( `ENDCLASS.` )
        ( `CLASS lcl_l3 IMPLEMENTATION.` )
        ( `ENDCLASS.` )
        ( `CLASS lcl_l4 DEFINITION INHERITING FROM lcl_l3.` )
        ( `ENDCLASS.` )
        ( `CLASS lcl_l4 IMPLEMENTATION.` )
        ( `ENDCLASS.` )
        ( `CLASS lcl_child DEFINITION INHERITING FROM lcl_l4.` )
        ( `ENDCLASS.` )
        ( `CLASS lcl_child IMPLEMENTATION.` )
        ( `ENDCLASS.` )
        ( `CLASS lcl_b1 DEFINITION.` )
        ( `ENDCLASS.` )
        ( `CLASS lcl_b1 IMPLEMENTATION.` )
        ( `ENDCLASS.` )
        ( `CLASS lcl_b2 DEFINITION INHERITING FROM lcl_b1.` )
        ( `ENDCLASS.` )
        ( `CLASS lcl_b2 IMPLEMENTATION.` )
        ( `ENDCLASS.` )
        ( `CLASS lcl_b3 DEFINITION INHERITING FROM lcl_b2.` )
        ( `ENDCLASS.` )
        ( `CLASS lcl_b3 IMPLEMENTATION.` )
        ( `ENDCLASS.` )
        ( `` )
        ( `CLASS zcl_skylint_test_057 DEFINITION` )
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
        ( `CLASS zcl_skylint_test_057 IMPLEMENTATION.` )
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
        io_check    = NEW zcl_skylint_check_057( )
        it_source   = lt_source
        it_expected = VALUE #( ( method = 'TEST_001' )
                                                         ( method = 'TEST_002' )
                                                         ( method = 'TEST_003' )
                                                         ( method = 'TEST_004' ) ) ).
  ENDMETHOD.
ENDCLASS.
