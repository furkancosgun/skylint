CLASS ltcl_check_010 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_check FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_010 IMPLEMENTATION.
  METHOD test_check.
    DATA lt_source TYPE string_table.

    lt_source = VALUE #(
        ( `CLASS zcl_skylint_test_010 DEFINITION` )
        ( `  PUBLIC FINAL` )
        ( `  CREATE PUBLIC.` )
        ( `` )
        ( `  PUBLIC SECTION.` )
        ( `    METHODS test_001.` )
        ( `    METHODS test_002.` )
        ( `    METHODS test_003.` )
        ( `    METHODS test_004.` )
        ( `    METHODS is_valid RETURNING VALUE(rv_flag) TYPE abap_bool.` )
        ( `ENDCLASS.` )
        ( `` )
        ( `CLASS zcl_skylint_test_010 IMPLEMENTATION.` )
        ( `  METHOD is_valid.` )
        ( `    rv_flag = abap_true.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_001.` )
        ( `    DATA lo_validator TYPE REF TO zcl_skylint_test_010.` )
        ( `    IF lo_validator->is_valid( ) = abap_true.` )
        ( `    ENDIF.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_002.` )
        ( `    DATA lo_validator TYPE REF TO zcl_skylint_test_010.` )
        ( `    DATA lv_flag TYPE abap_bool.` )
        ( `    IF lo_validator->is_valid( ).` )
        ( `    ENDIF.` )
        ( `    IF lv_flag = abap_true.` )
        ( `    ENDIF.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_003.` )
        ( `    DATA lo_validator TYPE REF TO zcl_skylint_test_010.` )
        ( `    WHILE lo_validator->is_valid( ) <> abap_false.` )
        ( `    ENDWHILE.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_004.` )
        ( `    DATA lo_validator TYPE REF TO zcl_skylint_test_010.` )
        ( `    WHILE lo_validator->is_valid( ).` )
        ( `    ENDWHILE.` )
        ( `  ENDMETHOD.` )
        ( `ENDCLASS.` ) ).

    zcl_skylint_test_runner=>run(
        io_check    = NEW zcl_skylint_check_010( )
        it_source   = lt_source
        it_expected = VALUE #(
            ( method = 'TEST_001' code = zcl_skylint_check_010=>c_finding_codes-bool_comparison line = 3 column = 4 )
            ( method = 'TEST_002' )
            ( method = 'TEST_003' code = zcl_skylint_check_010=>c_finding_codes-bool_comparison line = 3 column = 4 )
            ( method = 'TEST_004' ) ) ).
  ENDMETHOD.
ENDCLASS.
