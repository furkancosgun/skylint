CLASS ltcl_check_033 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_check FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_033 IMPLEMENTATION.
  METHOD test_check.
    DATA lt_source TYPE string_table.

    lt_source = VALUE #(
        ( `CLASS zcl_skylint_test_033 DEFINITION` )
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
        ( `CLASS zcl_skylint_test_033 IMPLEMENTATION.` )
        ( `  METHOD test_001.` )
        ( `    DATA lv_flag TYPE abap_bool.` )
        ( `    IF lv_flag = abap_true.` )
        ( `    DATA lv_inner TYPE i.` )
        ( `    ENDIF.` )
        ( `    lv_inner = 1.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_002.` )
        ( `    DATA lv_val TYPE i.` )
        ( `    lv_val = 1.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_003.` )
        ( `    DATA lt_tab TYPE STANDARD TABLE OF i WITH DEFAULT KEY.` )
        ( `    DATA lv_x TYPE i.` )
        ( `    LOOP AT lt_tab INTO lv_x.` )
        ( `      DATA lv_inner2 TYPE i.` )
        ( `    ENDLOOP.` )
        ( `    lv_inner2 = 1.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_004.` )
        ( `    DATA lv_flag TYPE abap_bool.` )
        ( `    IF lv_flag = abap_true.` )
        ( `      DATA lv_tmp TYPE i.` )
        ( `      lv_tmp = 1.` )
        ( `    ENDIF.` )
        ( `  ENDMETHOD.` )
        ( `ENDCLASS.` )
        ( `` ) ).

    zcl_skylint_test_runner=>run(
        io_check    = NEW zcl_skylint_check_033( )
        it_source   = lt_source
        it_expected = VALUE #(
            ( method = 'TEST_001' code = zcl_skylint_check_033=>c_finding_codes-scope_leak line = 6 column = 4 )
            ( method = 'TEST_002' )
            ( method = 'TEST_003' code = zcl_skylint_check_033=>c_finding_codes-scope_leak line = 7 column = 4 )
            ( method = 'TEST_004' ) ) ).
  ENDMETHOD.
ENDCLASS.
