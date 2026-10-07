CLASS ltcl_check_030 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_check FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_030 IMPLEMENTATION.
  METHOD test_check.
    DATA lt_source TYPE string_table.

    lt_source = VALUE #(
        ( `CLASS zcl_skylint_test_030 DEFINITION` )
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
        ( `CLASS zcl_skylint_test_030 IMPLEMENTATION.` )
        ( `  METHOD test_001.` )
        ( `    DATA lt_tab TYPE STANDARD TABLE OF zskylint_dummy WITH DEFAULT KEY.` )
        ( `    DATA ls_row TYPE zskylint_dummy.` )
        ( `    DATA ls_key TYPE string.` )
        ( `    LOOP AT lt_tab INTO ls_row.` )
        ( `      SELECT SINGLE * FROM zskylint_dummy INTO @ls_row WHERE field1 = @ls_key.` )
        ( `    ENDLOOP.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_002.` )
        ( `    DATA ls_row TYPE zskylint_dummy.` )
        ( `    DATA ls_key TYPE string.` )
        ( `    SELECT SINGLE * FROM zskylint_dummy INTO @ls_row WHERE field1 = @ls_key.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_003.` )
        ( `    DATA lt_tab TYPE STANDARD TABLE OF zskylint_dummy WITH DEFAULT KEY.` )
        ( `    DATA ls_row TYPE zskylint_dummy.` )
        ( `    DATA ls_key TYPE string.` )
        ( `    DO 2 TIMES.` )
        ( `      SELECT SINGLE * FROM zskylint_dummy INTO @ls_row WHERE field1 = @ls_key.` )
        ( `    ENDDO.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_004.` )
        ( `    DATA ls_key TYPE string.` )
        ( `    UPDATE zskylint_dummy SET field1 = ls_key WHERE field1 = ls_key.` )
        ( `  ENDMETHOD.` )
        ( `ENDCLASS.` ) ).

    zcl_skylint_test_runner=>run(
        io_check    = NEW zcl_skylint_check_030( )
        it_source   = lt_source
        it_expected = VALUE #(
            ( method = 'TEST_001' code = zcl_skylint_check_030=>c_finding_codes-db_in_loop line = 6 column = 6 )
            ( method = 'TEST_002' )
            ( method = 'TEST_003' code = zcl_skylint_check_030=>c_finding_codes-db_in_loop line = 6 column = 6 )
            ( method = 'TEST_004' ) ) ).
  ENDMETHOD.
ENDCLASS.
