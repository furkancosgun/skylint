CLASS ltcl_check_014 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_check FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_014 IMPLEMENTATION.
  METHOD test_check.
    DATA lt_source TYPE string_table.

    lt_source = VALUE #(
        ( `CLASS zcl_skylint_test_014 DEFINITION` )
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
        ( `CLASS zcl_skylint_test_014 IMPLEMENTATION.` )
        ( `  METHOD test_001.` )
        ( `    DATA lv_x TYPE i.` )
        ( `    IF lv_x = 1.` )
        ( `    ENDIF.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_002.` )
        ( `    DATA lv_x TYPE i.` )
        ( `    IF lv_x = 1.` )
        ( `    lv_x = 2.` )
        ( `    ENDIF.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_003.` )
        ( `    DATA lt_tab TYPE string_table.` )
        ( `    DATA ls_row TYPE string.` )
        ( `    LOOP AT lt_tab INTO ls_row.` )
        ( `    ENDLOOP.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_004.` )
        ( `    DATA lt_tab TYPE string_table.` )
        ( `    DATA ls_row TYPE string.` )
        ( `    DATA lv_n TYPE i.` )
        ( `    LOOP AT lt_tab INTO ls_row.` )
        ( `      lv_n = lv_n + 1.` )
        ( `    ENDLOOP.` )
        ( `  ENDMETHOD.` )
        ( `ENDCLASS.` )
        ( `` ) ).

    zcl_skylint_test_runner=>run(
        io_check    = NEW zcl_skylint_check_014( )
        it_source   = lt_source
        it_expected = VALUE #( ( method = 'TEST_001'
                               code = zcl_skylint_check_014=>c_finding_codes-empty_control_block line = 3 column = 4 )
                               ( method = 'TEST_002' )
                               ( method = 'TEST_003'
               code = zcl_skylint_check_014=>c_finding_codes-empty_control_block line = 4 column = 4 )
                               ( method = 'TEST_004' ) ) ).
  ENDMETHOD.
ENDCLASS.
