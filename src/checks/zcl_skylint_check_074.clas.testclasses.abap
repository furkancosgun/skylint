CLASS ltcl_check_074 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_check FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_074 IMPLEMENTATION.
  METHOD test_check.
    DATA lt_source TYPE string_table.

    lt_source = VALUE #(
        ( `CLASS zcl_skylint_test_074 DEFINITION` )
        ( `  PUBLIC FINAL` )
        ( `  CREATE PUBLIC.` )
        ( `` )
        ( `  PUBLIC SECTION.` )
        ( `    TYPES:` )
        ( `      BEGIN OF ty_row,` )
        ( `        flag TYPE abap_bool,` )
        ( `      END OF ty_row.` )
        ( `` )
        ( `    METHODS test_001.` )
        ( `    METHODS test_002.` )
        ( `    METHODS test_003.` )
        ( `    METHODS test_004.` )
        ( `ENDCLASS.` )
        ( `` )
        ( `CLASS zcl_skylint_test_074 IMPLEMENTATION.` )
        ( `  METHOD test_001.` )
        ( `    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.` )
        ( `    DATA ls_row TYPE ty_row.` )
        ( `    DATA ls_val TYPE i.` )
        ( `    LOOP AT lt_tab INTO ls_row.` )
        ( `      IF ls_row-flag = abap_true.` )
        ( `        ls_val = 1.` )
        ( `      ENDIF.` )
        ( `    ENDLOOP.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_002.` )
        ( `    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.` )
        ( `    DATA ls_row TYPE ty_row.` )
        ( `    DATA ls_val TYPE i.` )
        ( `    LOOP AT lt_tab INTO ls_row.` )
        ( `      ls_val = 1.` )
        ( `    ENDLOOP.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_003.` )
        ( `    DATA lv_flag TYPE abap_bool.` )
        ( `    DATA ls_val TYPE i.` )
        ( `    DO 5 TIMES.` )
        ( `      IF lv_flag = abap_true.` )
        ( `        ls_val = 1.` )
        ( `      ENDIF.` )
        ( `    ENDDO.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_004.` )
        ( `    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.` )
        ( `    DATA ls_row TYPE ty_row.` )
        ( `    DATA ls_val TYPE i.` )
        ( `    LOOP AT lt_tab INTO ls_row.` )
        ( `      IF ls_row-flag = abap_true.` )
        ( `        ls_val = 1.` )
        ( `      ELSE.` )
        ( `        ls_val = 2.` )
        ( `      ENDIF.` )
        ( `    ENDLOOP.` )
        ( `  ENDMETHOD.` )
        ( `ENDCLASS.` ) ).

    zcl_skylint_test_runner=>run(
        io_check    = NEW zcl_skylint_check_074( )
        it_source   = lt_source
        it_expected = VALUE #(
            ( method = 'TEST_001' code = zcl_skylint_check_074=>c_finding_codes-guard_loop line = 6 column = 6 )
            ( method = 'TEST_002' )
            ( method = 'TEST_003' code = zcl_skylint_check_074=>c_finding_codes-guard_loop line = 5 column = 6 )
            ( method = 'TEST_004' ) ) ).
  ENDMETHOD.
ENDCLASS.
