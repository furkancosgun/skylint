CLASS ltcl_check_040 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_check FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_040 IMPLEMENTATION.
  METHOD test_check.
    DATA lt_source TYPE string_table.

    lt_source = VALUE #(
        ( `CLASS zcl_skylint_test_040 DEFINITION` )
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
        ( `CLASS zcl_skylint_test_040 IMPLEMENTATION.` )
        ( `  METHOD test_001.` )
        ( `    DATA lv_a TYPE i.` )
        ( `    DATA lv_b TYPE i.` )
        ( `    DATA lv_c TYPE i.` )
        ( `    DATA lv_d TYPE i.` )
        ( `    IF lv_a = 1.` )
        ( `    IF lv_b = 2.` )
        ( `    IF lv_c = 3.` )
        ( `    IF lv_d = 4.` )
        ( `    ENDIF.` )
        ( `    ENDIF.` )
        ( `    ENDIF.` )
        ( `    ENDIF.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_002.` )
        ( `    DATA lv_a TYPE i.` )
        ( `    DATA lv_b TYPE i.` )
        ( `    IF lv_a = 1.` )
        ( `    IF lv_b = 2.` )
        ( `    ENDIF.` )
        ( `    ENDIF.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_003.` )
        ( `    DO 2 TIMES.` )
        ( `    DO 2 TIMES.` )
        ( `    DO 2 TIMES.` )
        ( `    DO 2 TIMES.` )
        ( `    ENDDO.` )
        ( `    ENDDO.` )
        ( `    ENDDO.` )
        ( `    ENDDO.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_004.` )
        ( `    DATA lv_a TYPE i.` )
        ( `    DATA lv_b TYPE i.` )
        ( `    DATA lv_c TYPE i.` )
        ( `    IF lv_a = 1.` )
        ( `    IF lv_b = 2.` )
        ( `    IF lv_c = 3.` )
        ( `    ENDIF.` )
        ( `    ENDIF.` )
        ( `    ENDIF.` )
        ( `  ENDMETHOD.` )
        ( `ENDCLASS.` )
        ( `` ) ).

    zcl_skylint_test_runner=>run(
        io_check    = NEW zcl_skylint_check_040( )
        it_source   = lt_source
        it_expected = VALUE #(
            ( method = 'TEST_001' code = zcl_skylint_check_040=>c_finding_codes-nesting_depth line = 9 column = 4 )
            ( method = 'TEST_002' )
            ( method = 'TEST_003' code = zcl_skylint_check_040=>c_finding_codes-nesting_depth line = 5 column = 4 )
            ( method = 'TEST_004' ) ) ).
  ENDMETHOD.
ENDCLASS.
