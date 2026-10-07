CLASS ltcl_check_055 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_check FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_055 IMPLEMENTATION.
  METHOD test_check.
    DATA lt_source TYPE string_table.

    lt_source = VALUE #(
        ( `CLASS lcl_helper DEFINITION.` )
        ( `  PUBLIC SECTION.` )
        ( `    CLASS-METHODS run.` )
        ( `ENDCLASS.` )
        ( `CLASS lcl_helper IMPLEMENTATION.` )
        ( `  METHOD run.` )
        ( `    RETURN.` )
        ( `  ENDMETHOD.` )
        ( `ENDCLASS.` )
        ( `` )
        ( `CLASS lcl_clean DEFINITION.` )
        ( `  PUBLIC SECTION.` )
        ( `    CLASS-METHODS run.` )
        ( `    METHODS execute.` )
        ( `ENDCLASS.` )
        ( `CLASS lcl_clean IMPLEMENTATION.` )
        ( `  METHOD run.` )
        ( `    RETURN.` )
        ( `  ENDMETHOD.` )
        ( `  METHOD execute.` )
        ( `    RETURN.` )
        ( `  ENDMETHOD.` )
        ( `ENDCLASS.` )
        ( `` )
        ( `CLASS lcl_util2 DEFINITION.` )
        ( `  PUBLIC SECTION.` )
        ( `    CLASS-METHODS run.` )
        ( `    CLASS-METHODS stop.` )
        ( `ENDCLASS.` )
        ( `CLASS lcl_util2 IMPLEMENTATION.` )
        ( `  METHOD run.` )
        ( `    RETURN.` )
        ( `  ENDMETHOD.` )
        ( `  METHOD stop.` )
        ( `    RETURN.` )
        ( `  ENDMETHOD.` )
        ( `ENDCLASS.` )
        ( `` )
        ( `CLASS lcl_mixed2 DEFINITION.` )
        ( `  PUBLIC SECTION.` )
        ( `    CLASS-METHODS run.` )
        ( `    METHODS execute.` )
        ( `ENDCLASS.` )
        ( `CLASS lcl_mixed2 IMPLEMENTATION.` )
        ( `  METHOD run.` )
        ( `    RETURN.` )
        ( `  ENDMETHOD.` )
        ( `  METHOD execute.` )
        ( `    RETURN.` )
        ( `  ENDMETHOD.` )
        ( `ENDCLASS.` )
        ( `` )
        ( `CLASS zcl_skylint_test_055 DEFINITION` )
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
        ( `CLASS zcl_skylint_test_055 IMPLEMENTATION.` )
        ( `  METHOD test_001.` )
        ( `    RETURN.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_002.` )
        ( `    RETURN.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_003.` )
        ( `    RETURN.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_004.` )
        ( `    DATA lv_val TYPE i.` )
        ( `    lv_val = 1.` )
        ( `  ENDMETHOD.` )
        ( `ENDCLASS.` ) ).

    zcl_skylint_test_runner=>run(
        io_check    = NEW zcl_skylint_check_055( )
        it_source   = lt_source
        it_expected = VALUE #(
            ( method = 'TEST_001' code = zcl_skylint_check_055=>c_finding_codes-static_class line = 1 column = 0 )
            ( method = 'TEST_002' )
            ( method = 'TEST_003' code = zcl_skylint_check_055=>c_finding_codes-static_class line = 1 column = 0 )
            ( method = 'TEST_004' ) ) ).
  ENDMETHOD.
ENDCLASS.
