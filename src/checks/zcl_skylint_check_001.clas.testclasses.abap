CLASS ltcl_check_001 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_check FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_001 IMPLEMENTATION.
  METHOD test_check.
    DATA lt_source TYPE string_table.

    lt_source = VALUE #(
        ( `CLASS zcl_skylint_test_001 DEFINITION` )
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
        ( `CLASS zcl_skylint_test_001 IMPLEMENTATION.` )
        ( `  METHOD test_001.` )
        ( `    DATA lv_cnt TYPE i.` )
        ( `    DATA lt_tab TYPE string_table.` )
        ( `    DESCRIBE TABLE lt_tab LINES lv_cnt.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_002.` )
        ( `    DATA lv_cnt TYPE i.` )
        ( `    DATA lt_tab TYPE string_table.` )
        ( `    lv_cnt = lines( lt_tab ).` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_003.` )
        ( `    DATA lv_lines TYPE i.` )
        ( `    DATA lt_items TYPE string_table.` )
        ( `    DESCRIBE TABLE lt_items LINES lv_lines.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_004.` )
        ( `    DATA lt_tab TYPE string_table.` )
        ( `    DATA lv_cnt TYPE i.` )
        ( `    IF lines( lt_tab ) > 0.` )
        ( `      lv_cnt = lines( lt_tab ).` )
        ( `    ENDIF.` )
        ( `  ENDMETHOD.` )
        ( `ENDCLASS.` )
        ( `` ) ).

    zcl_skylint_test_runner=>run(
        io_check    = NEW zcl_skylint_check_001( )
        it_source   = lt_source
        it_expected = VALUE #(
            ( method = 'TEST_001' code = zcl_skylint_check_001=>c_finding_codes-describe_lines line = 4 column = 4 )
            ( method = 'TEST_002' )
            ( method = 'TEST_003' code = zcl_skylint_check_001=>c_finding_codes-describe_lines line = 4 column = 4 )
            ( method = 'TEST_004' ) ) ).
  ENDMETHOD.
ENDCLASS.
