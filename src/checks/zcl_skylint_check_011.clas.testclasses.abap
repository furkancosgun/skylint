CLASS ltcl_check_011 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_check FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_011 IMPLEMENTATION.
  METHOD test_check.
    DATA lt_source TYPE string_table.

    lt_source = VALUE #(
        ( `CLASS zcl_skylint_test_011 DEFINITION` )
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
        ( `CLASS zcl_skylint_test_011 IMPLEMENTATION.` )
        ( `  METHOD test_001.` )
        ( `    DATA lt_tab TYPE string_table.` )
        ( `    READ TABLE lt_tab TRANSPORTING NO FIELDS WITH KEY table_line = ''.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_002.` )
        ( `    DATA lt_tab TYPE string_table.` )
        ( `    DATA ls_row TYPE string.` )
        ( `    READ TABLE lt_tab INTO ls_row INDEX 1.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_003.` )
        ( `    DATA lt_tab TYPE string_table.` )
        ( `    DATA lv_key TYPE string.` )
        ( `    READ TABLE lt_tab TRANSPORTING NO FIELDS WITH KEY table_line = lv_key.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_004.` )
        ( `    DATA lt_tab TYPE string_table.` )
        ( `    IF line_exists( lt_tab[ 1 ] ).` )
        ( `    ENDIF.` )
        ( `  ENDMETHOD.` )
        ( `ENDCLASS.` ) ).

    zcl_skylint_test_runner=>run(
        io_check    = NEW zcl_skylint_check_011( )
        it_source   = lt_source
        it_expected = VALUE #(
            ( method = 'TEST_001' code = zcl_skylint_check_011=>c_finding_codes-prefer_line_exists line = 3 column = 4 )
            ( method = 'TEST_002' )
            ( method = 'TEST_003' code = zcl_skylint_check_011=>c_finding_codes-prefer_line_exists line = 4 column = 4 )
            ( method = 'TEST_004' ) ) ).
  ENDMETHOD.
ENDCLASS.
