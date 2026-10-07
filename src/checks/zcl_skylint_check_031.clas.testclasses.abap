CLASS ltcl_check_031 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_check FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_031 IMPLEMENTATION.
  METHOD test_check.
    DATA lt_source TYPE string_table.

    lt_source = VALUE #(
        ( `CLASS zcl_skylint_test_031 DEFINITION` )
        ( `  PUBLIC FINAL` )
        ( `  CREATE PUBLIC.` )
        ( `` )
        ( `  PUBLIC SECTION.` )
        ( `    TYPES:` )
        ( `      BEGIN OF ty_entry,` )
        ( `        field1 TYPE c LENGTH 10,` )
        ( `      END OF ty_entry.` )
        ( `    TYPES tt_entry TYPE STANDARD TABLE OF ty_entry WITH DEFAULT KEY.` )
        ( `` )
        ( `    METHODS test_001.` )
        ( `    METHODS test_002.` )
        ( `    METHODS test_003.` )
        ( `    METHODS test_004.` )
        ( `ENDCLASS.` )
        ( `` )
        ( `CLASS zcl_skylint_test_031 IMPLEMENTATION.` )
        ( `  METHOD test_001.` )
        ( `    DATA s TYPE tt_entry.` )
        ( `    DATA r TYPE STANDARD TABLE OF zskylint_dummy WITH DEFAULT KEY.` )
        ( `    SELECT * FROM zskylint_dummy INTO TABLE @r FOR ALL ENTRIES IN @s WHERE field1 = @s-field1.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_002.` )
        ( `    DATA s TYPE tt_entry.` )
        ( `    DATA r TYPE STANDARD TABLE OF zskylint_dummy WITH DEFAULT KEY.` )
        ( `    IF s IS NOT INITIAL.` )
        ( `      SELECT * FROM zskylint_dummy INTO TABLE @r FOR ALL ENTRIES IN @s WHERE field1 = @s-field1.` )
        ( `    ENDIF.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_003.` )
        ( `    DATA t TYPE tt_entry.` )
        ( `    DATA r2 TYPE STANDARD TABLE OF zskylint_dummy WITH DEFAULT KEY.` )
        ( `    SELECT * FROM zskylint_dummy INTO TABLE @r2 FOR ALL ENTRIES IN @t WHERE field1 = @t-field1.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_004.` )
        ( `    DATA s TYPE tt_entry.` )
        ( `    DATA r TYPE STANDARD TABLE OF zskylint_dummy WITH DEFAULT KEY.` )
        ( `    IF lines( s ) > 0.` )
        ( `      SELECT * FROM zskylint_dummy INTO TABLE @r FOR ALL ENTRIES IN @s WHERE field1 = @s-field1.` )
        ( `    ENDIF.` )
        ( `  ENDMETHOD.` )
        ( `ENDCLASS.` ) ).

    zcl_skylint_test_runner=>run(
        io_check    = NEW zcl_skylint_check_031( )
        it_source   = lt_source
        it_expected = VALUE #(
            ( method = 'TEST_001' code = zcl_skylint_check_031=>c_finding_codes-unsecure_fae line = 4 column = 4 )
            ( method = 'TEST_002' )
            ( method = 'TEST_003' code = zcl_skylint_check_031=>c_finding_codes-unsecure_fae line = 4 column = 4 )
            ( method = 'TEST_004' ) ) ).
  ENDMETHOD.
ENDCLASS.
