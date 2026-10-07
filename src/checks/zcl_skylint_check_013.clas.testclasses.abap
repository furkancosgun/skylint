CLASS ltcl_check_013 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_check FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_013 IMPLEMENTATION.
  METHOD test_check.
    DATA lt_source TYPE string_table.

    lt_source = VALUE #(
        ( `CLASS zcl_skylint_test_013 DEFINITION` )
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
        ( `CLASS zcl_skylint_test_013 IMPLEMENTATION.` )
        ( `  METHOD test_001.` )
        ( `    DATA lv_flag TYPE abap_bool.` )
        ( `    DATA lt_tab TYPE string_table.` )
        ( `    DATA ls_row TYPE string.` )
        ( `    LOOP AT lt_tab INTO ls_row.` )
        ( `      CHECK lv_flag = abap_true.` )
        ( `    ENDLOOP.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_002.` )
        ( `    DATA lv_flag TYPE abap_bool.` )
        ( `    CHECK lv_flag = abap_true.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_003.` )
        ( `    DATA lv_flag TYPE abap_bool.` )
        ( `    DO 5 TIMES.` )
        ( `      CHECK lv_flag = abap_true.` )
        ( `    ENDDO.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_004.` )
        ( `    DATA lt_tab TYPE string_table.` )
        ( `    DATA ls_row TYPE string.` )
        ( `    LOOP AT lt_tab INTO ls_row.` )
        ( `      IF ls_row IS INITIAL.` )
        ( `        CONTINUE.` )
        ( `      ENDIF.` )
        ( `    ENDLOOP.` )
        ( `  ENDMETHOD.` )
        ( `ENDCLASS.` ) ).

    zcl_skylint_test_runner=>run(
        io_check    = NEW zcl_skylint_check_013( )
        it_source   = lt_source
        it_expected = VALUE #(
            ( method = 'TEST_001' code = zcl_skylint_check_013=>c_finding_codes-check_in_loop line = 6 column = 6 )
            ( method = 'TEST_002' )
            ( method = 'TEST_003' code = zcl_skylint_check_013=>c_finding_codes-check_in_loop line = 4 column = 6 )
            ( method = 'TEST_004' ) ) ).
  ENDMETHOD.
ENDCLASS.
