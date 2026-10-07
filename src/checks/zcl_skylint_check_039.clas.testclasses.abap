CLASS ltcl_check_039 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_check FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_039 IMPLEMENTATION.
  METHOD test_check.
    DATA lt_source TYPE string_table.

    lt_source = VALUE #(
        ( `CLASS zcl_skylint_test_039 DEFINITION` )
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
        ( `CLASS zcl_skylint_test_039 IMPLEMENTATION.` )
        ( `  METHOD test_001.` )
        ( `    DATA lv_a TYPE i.` )
        ( `    DATA lv_b TYPE i.` )
        ( `    DATA lv_c TYPE i.` )
        ( `    DATA lv_d TYPE i.` )
        ( `    DATA lv_e TYPE i.` )
        ( `    DATA lv_f TYPE i.` )
        ( `    lv_a = 1.` )
        ( `    lv_b = 2.` )
        ( `    lv_c = 3.` )
        ( `    lv_d = 4.` )
        ( `    lv_e = 5.` )
        ( `    lv_f = 6.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_002.` )
        ( `    DATA lv_a TYPE i.` )
        ( `    DATA lv_b TYPE i.` )
        ( `    lv_a = 1.` )
        ( `    lv_b = 2.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_003.` )
        ( `    DATA lv_m TYPE i.` )
        ( `    DATA lv_n TYPE i.` )
        ( `    DATA lv_o TYPE i.` )
        ( `    lv_m = 1.` )
        ( `    lv_n = 2.` )
        ( `    lv_o = 3.` )
        ( `    lv_m = lv_n.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_004.` )
        ( `    DATA lv_p TYPE i.` )
        ( `    DATA lv_q TYPE i.` )
        ( `    DATA lv_r TYPE i.` )
        ( `    lv_p = 1.` )
        ( `    lv_q = 2.` )
        ( `  ENDMETHOD.` )
        ( `ENDCLASS.` )
        ( `` ) ).

    zcl_skylint_test_runner=>run(
        io_check    = NEW zcl_skylint_check_039( )
        it_source   = lt_source
        it_expected = VALUE #(
            ( method = 'TEST_001' code = zcl_skylint_check_039=>c_finding_codes-method_length line = 1 column = 2 )
            ( method = 'TEST_002' )
            ( method = 'TEST_003' code = zcl_skylint_check_039=>c_finding_codes-method_length line = 1 column = 2 )
            ( method = 'TEST_004' ) ) ).
  ENDMETHOD.
ENDCLASS.
