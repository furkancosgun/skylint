CLASS ltcl_check_052 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_check FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_052 IMPLEMENTATION.
  METHOD test_check.
    DATA lt_source TYPE string_table.

    lt_source = VALUE #(
        ( `CLASS zcl_skylint_test_052 DEFINITION` )
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
        ( `CLASS zcl_skylint_test_052 IMPLEMENTATION.` )
        ( `  METHOD test_001.` )
        ( `    DATA lt_tab TYPE string_table.` )
        ( `    DATA ls_row TYPE string.` )
        ( `    LOOP AT lt_tab INTO ls_row.` )
        ( `      AT NEW table_line.` )
        ( `      ENDAT.` )
        ( `    ENDLOOP.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_002.` )
        ( `    DATA lt_tab TYPE string_table.` )
        ( `    DATA ls_row TYPE string.` )
        ( `    LOOP AT lt_tab INTO ls_row.` )
        ( `      CONTINUE.` )
        ( `    ENDLOOP.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_003.` )
        ( `    DATA lt_tab TYPE string_table.` )
        ( `    DATA ls_row TYPE string.` )
        ( `    LOOP AT lt_tab INTO ls_row.` )
        ( `      AT END OF table_line.` )
        ( `      ENDAT.` )
        ( `    ENDLOOP.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_004.` )
        ( `    DATA lv_a TYPE i.` )
        ( `    DO 1 TIMES.` )
        ( `    ENDDO.` )
        ( `  ENDMETHOD.` )
        ( `ENDCLASS.` ) ).

    zcl_skylint_test_runner=>run(
        io_check    = NEW zcl_skylint_check_052( )
        it_source   = lt_source
        it_expected = VALUE #(
                                      ( method = 'TEST_001'
               code = zcl_skylint_check_052=>c_finding_codes-obsolete_loop_control line = 5 column = 6 )
                                      ( method = 'TEST_002' )
                                      ( method = 'TEST_003'
               code = zcl_skylint_check_052=>c_finding_codes-obsolete_loop_control line = 5 column = 6 )
                                      ( method = 'TEST_004' ) ) ).
  ENDMETHOD.
ENDCLASS.
