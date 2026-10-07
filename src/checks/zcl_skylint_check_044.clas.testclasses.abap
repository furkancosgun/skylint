CLASS ltcl_check_044 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_check FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_044 IMPLEMENTATION.
  METHOD test_check.
    DATA lt_source TYPE string_table.

    lt_source = VALUE #(
        ( `CLASS zcl_skylint_test_044 DEFINITION` )
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
        ( `CLASS zcl_skylint_test_044 IMPLEMENTATION.` )
        ( `  METHOD test_001.` )
        ( `    DATA lv_msg TYPE string.` )
        ( `    DATA lv_lin TYPE i.` )
        ( `    DATA lv_wrd TYPE string.` )
        ( `    DATA lt_prog TYPE string_table.` )
        ( `    SYNTAX-CHECK FOR lt_prog MESSAGE lv_msg LINE lv_lin WORD lv_wrd.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_002.` )
        ( `    DATA lv_flag TYPE abap_bool.` )
        ( `    CHECK lv_flag = abap_true.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_003.` )
        ( `    DELETE REPORT 'ZFOO'.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_004.` )
        ( `    DATA lv_flag TYPE abap_bool.` )
        ( `    IF lv_flag = abap_true.` )
        ( `    ENDIF.` )
        ( `  ENDMETHOD.` )
        ( `ENDCLASS.` )
        ( `` ) ).

    zcl_skylint_test_runner=>run(
        io_check    = NEW zcl_skylint_check_044( )
        it_source   = lt_source
        it_expected = VALUE #( ( method = 'TEST_001'
                               code = zcl_skylint_check_044=>c_finding_codes-dangerous_statement line = 6 column = 4 )
                               ( method = 'TEST_002' )
                               ( method = 'TEST_003'
               code = zcl_skylint_check_044=>c_finding_codes-dangerous_statement line = 2 column = 4 )
                               ( method = 'TEST_004' ) ) ).
  ENDMETHOD.
ENDCLASS.
