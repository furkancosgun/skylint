CLASS ltcl_check_025 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_check FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_025 IMPLEMENTATION.
  METHOD test_check.
    DATA lt_source TYPE string_table.

    lt_source = VALUE #(
        ( `CLASS zcl_skylint_test_025 DEFINITION` )
        ( `  PUBLIC FINAL` )
        ( `  CREATE PUBLIC.` )
        ( `` )
        ( `  PUBLIC SECTION.` )
        ( `    METHODS test_001.` )
        ( `    METHODS test_002.` )
        ( `    METHODS test_003.` )
        ( `    METHODS test_004.` )
        ( `    METHODS run` )
        ( `      IMPORTING iv_in TYPE i OPTIONAL` )
        ( `      RETURNING VALUE(rv_val) TYPE i.` )
        ( `ENDCLASS.` )
        ( `` )
        ( `CLASS zcl_skylint_test_025 IMPLEMENTATION.` )
        ( `  METHOD run.` )
        ( `    rv_val = iv_in.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_001.` )
        ( `    DATA lo_obj TYPE REF TO zcl_skylint_test_025.` )
        ( `    DATA lv_x TYPE i.` )
        ( `    CALL METHOD lo_obj->run RECEIVING rv_val = lv_x.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_002.` )
        ( `    DATA lo_obj TYPE REF TO zcl_skylint_test_025.` )
        ( `    DATA lv_x TYPE i.` )
        ( `    CALL METHOD lo_obj->run EXPORTING iv_in = lv_x.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_003.` )
        ( `    DATA lo_obj TYPE REF TO zcl_skylint_test_025.` )
        ( `    DATA lv_x TYPE i.` )
        ( `    CALL METHOD lo_obj->run EXPORTING iv_in = lv_x RECEIVING rv_val = lv_x.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_004.` )
        ( `    DATA lo_obj TYPE REF TO zcl_skylint_test_025.` )
        ( `    DATA lv_x TYPE i.` )
        ( `    lv_x = lo_obj->run( iv_in = lv_x ).` )
        ( `  ENDMETHOD.` )
        ( `ENDCLASS.` ) ).

    zcl_skylint_test_runner=>run(
        io_check    = NEW zcl_skylint_check_025( )
        it_source   = lt_source
        it_expected = VALUE #(
            ( method = 'TEST_001' code = zcl_skylint_check_025=>c_finding_codes-omit_receiving line = 4 column = 4 )
            ( method = 'TEST_002' )
            ( method = 'TEST_003' code = zcl_skylint_check_025=>c_finding_codes-omit_receiving line = 4 column = 4 )
            ( method = 'TEST_004' ) ) ).
  ENDMETHOD.
ENDCLASS.
