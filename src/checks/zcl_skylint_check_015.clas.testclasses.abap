CLASS ltcl_check_015 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_check FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_015 IMPLEMENTATION.
  METHOD test_check.
    DATA lt_source TYPE string_table.

    lt_source = VALUE #(
        ( `CLASS zcl_skylint_test_015 DEFINITION` )
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
        ( `CLASS zcl_skylint_test_015 IMPLEMENTATION.` )
        ( `  METHOD test_001.` )
        ( `    TRY.` )
        ( `    CATCH cx_root.` )
        ( `    ENDTRY.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_002.` )
        ( `    DATA lv_x TYPE i.` )
        ( `    TRY.` )
        ( `    CATCH cx_root.` )
        ( `    lv_x = 1.` )
        ( `    ENDTRY.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_003.` )
        ( `    TRY.` )
        ( `    CATCH cx_static_check.` )
        ( `    CATCH cx_root.` )
        ( `      MESSAGE 'err' TYPE 'E'.` )
        ( `    ENDTRY.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_004.` )
        ( `    TRY.` )
        ( `    CATCH cx_root.` )
        ( `      RETURN.` )
        ( `    ENDTRY.` )
        ( `  ENDMETHOD.` )
        ( `ENDCLASS.` )
        ( `` ) ).

    zcl_skylint_test_runner=>run(
        io_check    = NEW zcl_skylint_check_015( )
        it_source   = lt_source
        it_expected = VALUE #(
            ( method = 'TEST_001' code = zcl_skylint_check_015=>c_finding_codes-empty_catch line = 3 column = 4 )
            ( method = 'TEST_002' )
            ( method = 'TEST_003' code = zcl_skylint_check_015=>c_finding_codes-empty_catch line = 3 column = 4 )
            ( method = 'TEST_004' ) ) ).
  ENDMETHOD.
ENDCLASS.
