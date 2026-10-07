CLASS ltcl_check_075 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_check FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_075 IMPLEMENTATION.
  METHOD test_check.
    DATA lt_source TYPE string_table.

    lt_source = VALUE #(
        ( `CLASS zcl_skylint_test_075 DEFINITION` )
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
        ( `CLASS zcl_skylint_test_075 IMPLEMENTATION.` )
        ( `  METHOD test_001.` )
        ( `    DATA lv_flag TYPE abap_bool.` )
        ( `    DATA ls_val TYPE i.` )
        ( `    IF lv_flag = abap_true.` )
        ( `    ls_val = 1.` )
        ( `    ENDIF.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_002.` )
        ( `    DATA lv_flag TYPE abap_bool.` )
        ( `    DATA ls_val TYPE i.` )
        ( `    IF lv_flag = abap_true.` )
        ( `    ls_val = 1.` )
        ( `    ELSE.` )
        ( `    ls_val = 2.` )
        ( `    ENDIF.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_003.` )
        ( `    DATA lv_other TYPE abap_bool.` )
        ( `    DATA ls_val TYPE i.` )
        ( `    IF lv_other = abap_false.` )
        ( `      ls_val = 2.` )
        ( `    ENDIF.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_004.` )
        ( `    DATA lv_flag TYPE abap_bool.` )
        ( `    DATA ls_val TYPE i.` )
        ( `    ls_val = 0.` )
        ( `    IF lv_flag = abap_true.` )
        ( `      ls_val = 1.` )
        ( `    ENDIF.` )
        ( `  ENDMETHOD.` )
        ( `ENDCLASS.` )
        ( `` ) ).

    zcl_skylint_test_runner=>run(
        io_check    = NEW zcl_skylint_check_075( )
        it_source   = lt_source
        it_expected = VALUE #(
            ( method = 'TEST_001' code = zcl_skylint_check_075=>c_finding_codes-guard_method line = 4 column = 4 )
            ( method = 'TEST_002' )
            ( method = 'TEST_003' code = zcl_skylint_check_075=>c_finding_codes-guard_method line = 4 column = 4 )
            ( method = 'TEST_004' ) ) ).
  ENDMETHOD.
ENDCLASS.
