CLASS ltcl_check_018 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_check FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_018 IMPLEMENTATION.
  METHOD test_check.
    DATA lt_source TYPE string_table.

    lt_source = VALUE #(
        ( `CLASS zcl_skylint_test_018 DEFINITION` )
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
        ( `CLASS zcl_skylint_test_018 IMPLEMENTATION.` )
        ( `  METHOD test_001.` )
        ( `    DATA lv_x TYPE i.` )
        ( `    RETURN.` )
        ( `    lv_x = 1.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_002.` )
        ( `    DATA lv_x TYPE i.` )
        ( `    lv_x = 1.` )
        ( `    RETURN.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_003.` )
        ( `    DATA lt_tab TYPE string_table.` )
        ( `    DATA ls_row TYPE string.` )
        ( `    LOOP AT lt_tab INTO ls_row.` )
        ( `      EXIT.` )
        ( `      ls_row = 'x'.` )
        ( `    ENDLOOP.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_004.` )
        ( `    DATA lv_x TYPE i.` )
        ( `    IF lv_x = 1.` )
        ( `      RETURN.` )
        ( `    ENDIF.` )
        ( `    lv_x = 2.` )
        ( `  ENDMETHOD.` )
        ( `ENDCLASS.` )
        ( `` ) ).

    zcl_skylint_test_runner=>run(
        io_check    = NEW zcl_skylint_check_018( )
        it_source   = lt_source
        it_expected = VALUE #(
            ( method = 'TEST_001' code = zcl_skylint_check_018=>c_finding_codes-unreachable_code line = 4 column = 4 )
            ( method = 'TEST_002' )
            ( method = 'TEST_003' code = zcl_skylint_check_018=>c_finding_codes-unreachable_code line = 6 column = 6 )
            ( method = 'TEST_004' ) ) ).
  ENDMETHOD.
ENDCLASS.
