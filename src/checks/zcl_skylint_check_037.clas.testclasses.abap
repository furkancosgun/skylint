CLASS ltcl_check_037 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_check FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_037 IMPLEMENTATION.
  METHOD test_check.
    DATA lt_source TYPE string_table.

    lt_source = VALUE #(
        ( `CLASS zcl_skylint_test_037 DEFINITION` )
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
        ( `CLASS zcl_skylint_test_037 IMPLEMENTATION.` )
        ( `  METHOD test_001.` )
        ( `    TRY.` )
        ( `    ENDTRY.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_002.` )
        ( `    TRY.` )
        ( `    CATCH cx_root.` )
        ( `    ENDTRY.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_003.` )
        ( `    DATA lv_y TYPE i.` )
        ( `    TRY.` )
        ( `      lv_y = 1.` )
        ( `    ENDTRY.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_004.` )
        ( `    TRY.` )
        ( `    CATCH cx_sy_zerodivide.` )
        ( `    ENDTRY.` )
        ( `  ENDMETHOD.` )
        ( `ENDCLASS.` )
        ( `` ) ).

    zcl_skylint_test_runner=>run(
        io_check    = NEW zcl_skylint_check_037( )
        it_source   = lt_source
        it_expected = VALUE #(
            ( method = 'TEST_001' code = zcl_skylint_check_037=>c_finding_codes-try_without_catch line = 2 column = 4 )
            ( method = 'TEST_002' )
            ( method = 'TEST_003' code = zcl_skylint_check_037=>c_finding_codes-try_without_catch line = 3 column = 4 )
            ( method = 'TEST_004' ) ) ).
  ENDMETHOD.
ENDCLASS.
