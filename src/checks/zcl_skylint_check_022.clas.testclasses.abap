CLASS ltcl_check_022 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_check FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_022 IMPLEMENTATION.
  METHOD test_check.
    DATA lt_source TYPE string_table.

    lt_source = VALUE #(
        ( `CLASS zcl_skylint_test_022 DEFINITION` )
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
        ( `CLASS zcl_skylint_test_022 IMPLEMENTATION.` )
        ( `  METHOD test_001.` )
        ( `    DATA lo_obj TYPE REF TO zcl_skylint_test_022.` )
        ( `    CREATE OBJECT lo_obj.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_002.` )
        ( `    DATA lo_obj TYPE REF TO zcl_skylint_test_022.` )
        ( `    DATA lv_cls TYPE string.` )
        ( `    CREATE OBJECT lo_obj TYPE (lv_cls).` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_003.` )
        ( `    DATA lo_other TYPE REF TO zcl_skylint_test_022.` )
        ( `    CREATE OBJECT lo_other.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_004.` )
        ( `    DATA lo_obj TYPE REF TO zcl_skylint_test_022.` )
        ( `    lo_obj = NEW #( ).` )
        ( `  ENDMETHOD.` )
        ( `ENDCLASS.` ) ).

    zcl_skylint_test_runner=>run(
        io_check    = NEW zcl_skylint_check_022( )
        it_source   = lt_source
        it_expected = VALUE #(
            ( method = 'TEST_001' code = zcl_skylint_check_022=>c_finding_codes-prefer_new line = 3 column = 4 )
            ( method = 'TEST_002' )
            ( method = 'TEST_003' code = zcl_skylint_check_022=>c_finding_codes-prefer_new line = 3 column = 4 )
            ( method = 'TEST_004' ) ) ).
  ENDMETHOD.
ENDCLASS.
