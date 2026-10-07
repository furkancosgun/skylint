CLASS ltcl_check_056 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_check FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_056 IMPLEMENTATION.
  METHOD test_check.
    DATA lt_source TYPE string_table.

    lt_source = VALUE #(
        ( `CLASS lcl_bad DEFINITION.` )
        ( `  PUBLIC SECTION.` )
        ( `    METHODS get_status RETURNING VALUE(rv_flag) TYPE abap_bool.` )
        ( `ENDCLASS.` )
        ( `CLASS lcl_bad IMPLEMENTATION.` )
        ( `  METHOD get_status.` )
        ( `    rv_flag = abap_true.` )
        ( `  ENDMETHOD.` )
        ( `ENDCLASS.` )
        ( `` )
        ( `CLASS lcl_clean DEFINITION.` )
        ( `  PUBLIC SECTION.` )
        ( `    METHODS is_valid RETURNING VALUE(rv_flag) TYPE abap_bool.` )
        ( `ENDCLASS.` )
        ( `CLASS lcl_clean IMPLEMENTATION.` )
        ( `  METHOD is_valid.` )
        ( `    rv_flag = abap_true.` )
        ( `  ENDMETHOD.` )
        ( `ENDCLASS.` )
        ( `` )
        ( `CLASS lcl_calc DEFINITION.` )
        ( `  PUBLIC SECTION.` )
        ( `    CLASS-METHODS validate_input RETURNING VALUE(rv_ok) TYPE flag.` )
        ( `ENDCLASS.` )
        ( `CLASS lcl_calc IMPLEMENTATION.` )
        ( `  METHOD validate_input.` )
        ( `    RETURN.` )
        ( `  ENDMETHOD.` )
        ( `ENDCLASS.` )
        ( `` )
        ( `CLASS lcl_state DEFINITION.` )
        ( `  PUBLIC SECTION.` )
        ( `    METHODS has_entries RETURNING VALUE(rv_flag) TYPE xfeld.` )
        ( `ENDCLASS.` )
        ( `CLASS lcl_state IMPLEMENTATION.` )
        ( `  METHOD has_entries.` )
        ( `    rv_flag = abap_true.` )
        ( `  ENDMETHOD.` )
        ( `ENDCLASS.` )
        ( `` )
        ( `CLASS zcl_skylint_test_056 DEFINITION` )
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
        ( `CLASS zcl_skylint_test_056 IMPLEMENTATION.` )
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
        io_check    = NEW zcl_skylint_check_056( )
        it_source   = lt_source
        it_expected = VALUE #(
            ( method = 'TEST_001' code = zcl_skylint_check_056=>c_finding_codes-bool_method_name line = 3 column = 4 )
            ( method = 'TEST_002' )
            ( method = 'TEST_003' code = zcl_skylint_check_056=>c_finding_codes-bool_method_name line = 3 column = 4 )
            ( method = 'TEST_004' ) ) ).
  ENDMETHOD.
ENDCLASS.
