CLASS ltcl_check_059 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_check FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_059 IMPLEMENTATION.
  METHOD test_check.
    DATA lt_source TYPE string_table.

    lt_source = VALUE #(
        ( `INTERFACE lif_test.` )
        ( `  DATA mv_state TYPE i.` )
        ( `ENDINTERFACE.` )
        ( `` )
        ( `INTERFACE lif_clean.` )
        ( `  CONSTANTS c_version TYPE i VALUE 1.` )
        ( `ENDINTERFACE.` )
        ( `` )
        ( `INTERFACE lif_state2.` )
        ( `  CLASS-DATA gv_counter TYPE i.` )
        ( `ENDINTERFACE.` )
        ( `` )
        ( `INTERFACE lif_consts2.` )
        ( `  CONSTANTS c_max TYPE i VALUE 100.` )
        ( `ENDINTERFACE.` )
        ( `` )
        ( `CLASS zcl_skylint_test_059 DEFINITION` )
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
        ( `CLASS zcl_skylint_test_059 IMPLEMENTATION.` )
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
        io_check    = NEW zcl_skylint_check_059( )
        it_source   = lt_source
        it_expected = VALUE #(
            ( method = 'TEST_001' code = zcl_skylint_check_059=>c_finding_codes-interface_data line = 2 column = 2 )
            ( method = 'TEST_002' )
            ( method = 'TEST_003' code = zcl_skylint_check_059=>c_finding_codes-interface_data line = 2 column = 2 )
            ( method = 'TEST_004' ) ) ).
  ENDMETHOD.
ENDCLASS.
