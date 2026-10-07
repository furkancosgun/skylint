CLASS ltcl_check_062 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_check FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_062 IMPLEMENTATION.
  METHOD test_check.
    DATA lt_source TYPE string_table.

    lt_source = VALUE #(
        ( `CLASS zcl_skylint_test_062 DEFINITION` )
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
        ( `CLASS zcl_skylint_test_062 IMPLEMENTATION.` )
        ( `  METHOD test_001.` )
        ( `    TRY.` )
        ( `      TRY.` )
        ( `      CATCH cx_root.` )
        ( `      ENDTRY.` )
        ( `    CATCH cx_root.` )
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
        ( `    TRY.` )
        ( `      DATA lv_val TYPE i.` )
        ( `      TRY.` )
        ( `      CATCH cx_sy_zerodivide.` )
        ( `      ENDTRY.` )
        ( `    CATCH cx_root.` )
        ( `    ENDTRY.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_004.` )
        ( `    TRY.` )
        ( `    CATCH cx_root.` )
        ( `    ENDTRY.` )
        ( `    TRY.` )
        ( `    CATCH cx_sy_zerodivide.` )
        ( `    ENDTRY.` )
        ( `  ENDMETHOD.` )
        ( `ENDCLASS.` ) ).

    zcl_skylint_test_runner=>run(
        io_check    = NEW zcl_skylint_check_062( )
        it_source   = lt_source
        it_expected = VALUE #(
            ( method = 'TEST_001' code = zcl_skylint_check_062=>c_finding_codes-nested_try line = 3 column = 6 )
            ( method = 'TEST_002' )
            ( method = 'TEST_003' code = zcl_skylint_check_062=>c_finding_codes-nested_try line = 4 column = 6 )
            ( method = 'TEST_004' ) ) ).
  ENDMETHOD.
ENDCLASS.
