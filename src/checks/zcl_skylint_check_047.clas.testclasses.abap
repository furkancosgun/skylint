CLASS ltcl_check_047 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_check FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_047 IMPLEMENTATION.
  METHOD test_check.
    DATA lt_source TYPE string_table.

    lt_source = VALUE #(
        ( `CLASS zcl_skylint_test_047 DEFINITION` )
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
        ( `CLASS zcl_skylint_test_047 IMPLEMENTATION.` )
        ( `  METHOD test_001.` )
        ( `    DATA lv_a TYPE i.` )
        ( `    DATA lv_b TYPE i.` )
        ( `    DATA lv_c TYPE i.` )
        ( `    DATA lv_d TYPE i.` )
        ( `    DATA lv_e TYPE i.` )
        ( `    IF lv_a = 1.` )
        ( `    ENDIF.` )
        ( `    IF lv_b = 2.` )
        ( `    ENDIF.` )
        ( `    IF lv_c = 3.` )
        ( `    ENDIF.` )
        ( `    IF lv_d = 4.` )
        ( `    ENDIF.` )
        ( `    IF lv_e = 5.` )
        ( `    ENDIF.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_002.` )
        ( `    DATA lv_a TYPE i.` )
        ( `    IF lv_a = 1.` )
        ( `    ENDIF.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_003.` )
        ( `    DATA lv_a TYPE i.` )
        ( `    DATA lv_b TYPE i.` )
        ( `    DATA lv_c TYPE i.` )
        ( `    IF lv_a = 1 AND lv_b = 2 OR lv_c = 3.` )
        ( `    ENDIF.` )
        ( `    WHILE lv_a < 10.` )
        ( `    ENDWHILE.` )
        ( `    IF lv_b = 4 AND lv_c = 5.` )
        ( `    ENDIF.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_004.` )
        ( `    DATA lv_a TYPE i.` )
        ( `    lv_a = 1.` )
        ( `  ENDMETHOD.` )
        ( `ENDCLASS.` )
        ( `` ) ).

    zcl_skylint_test_runner=>run(
        io_check    = NEW zcl_skylint_check_047( )
        it_source   = lt_source
        it_expected = VALUE #(
                                      ( method = 'TEST_001'
               code = zcl_skylint_check_047=>c_finding_codes-cyclomatic_complexity line = 1 column = 2 )
                                      ( method = 'TEST_002' )
                                      ( method = 'TEST_003'
               code = zcl_skylint_check_047=>c_finding_codes-cyclomatic_complexity line = 1 column = 2 )
                                      ( method = 'TEST_004' ) ) ).
  ENDMETHOD.
ENDCLASS.
