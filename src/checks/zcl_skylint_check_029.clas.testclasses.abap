CLASS ltcl_check_029 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_check FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_029 IMPLEMENTATION.
  METHOD test_check.
    DATA lt_source TYPE string_table.

    lt_source = VALUE #(
        ( `CLASS lcl_many_params DEFINITION.` )
        ( `  PUBLIC SECTION.` )
        ( `    METHODS run IMPORTING a TYPE i b TYPE i c TYPE i d TYPE i e TYPE i f TYPE i g TYPE i h TYPE i j TYPE i.` )
        ( `ENDCLASS.` )
        ( `CLASS lcl_many_params IMPLEMENTATION.` )
        ( `  METHOD run.` )
        ( `    RETURN.` )
        ( `  ENDMETHOD.` )
        ( `ENDCLASS.` )
        ( `` )
        ( `CLASS lcl_clean DEFINITION.` )
        ( `  PUBLIC SECTION.` )
        ( `    METHODS run IMPORTING a TYPE i b TYPE i.` )
        ( `ENDCLASS.` )
        ( `CLASS lcl_clean IMPLEMENTATION.` )
        ( `  METHOD run.` )
        ( `    RETURN.` )
        ( `  ENDMETHOD.` )
        ( `ENDCLASS.` )
        ( `` )
        ( `CLASS lcl_many_two DEFINITION.` )
        ( `  PUBLIC SECTION.` )
        ( `    METHODS run IMPORTING p1 TYPE i p2 TYPE i p3 TYPE i p4 TYPE i p5 TYPE i p6 TYPE i p7 TYPE i p8 TYPE i p9 TYPE i.` )
        ( `ENDCLASS.` )
        ( `CLASS lcl_many_two IMPLEMENTATION.` )
        ( `  METHOD run.` )
        ( `    RETURN.` )
        ( `  ENDMETHOD.` )
        ( `ENDCLASS.` )
        ( `` )
        ( `CLASS lcl_tidy DEFINITION.` )
        ( `  PUBLIC SECTION.` )
        ( `    METHODS run IMPORTING only_one TYPE i.` )
        ( `ENDCLASS.` )
        ( `CLASS lcl_tidy IMPLEMENTATION.` )
        ( `  METHOD run.` )
        ( `    RETURN.` )
        ( `  ENDMETHOD.` )
        ( `ENDCLASS.` )
        ( `` )
        ( `CLASS zcl_skylint_test_029 DEFINITION` )
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
        ( `CLASS zcl_skylint_test_029 IMPLEMENTATION.` )
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
        ( `    RETURN.` )
        ( `  ENDMETHOD.` )
        ( `ENDCLASS.` ) ).

    zcl_skylint_test_runner=>run(
        io_check    = NEW zcl_skylint_check_029( )
        it_source   = lt_source
        it_expected = VALUE #( ( method = 'TEST_001'
                               code = zcl_skylint_check_029=>c_finding_codes-too_many_parameters line = 3 column = 4 )
                               ( method = 'TEST_002' )
                               ( method = 'TEST_003'
               code = zcl_skylint_check_029=>c_finding_codes-too_many_parameters line = 3 column = 4 )
                               ( method = 'TEST_004' ) ) ).
  ENDMETHOD.
ENDCLASS.
