CLASS ltcl_check_016 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_check FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_016 IMPLEMENTATION.
  METHOD test_check.
    DATA lt_source TYPE string_table.

    lt_source = VALUE #(
        ( `CLASS zcl_skylint_test_016 DEFINITION` )
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
        ( `CLASS zcl_skylint_test_016 IMPLEMENTATION.` )
        ( `  METHOD test_001.` )
        ( `    DATA lv_a TYPE i.` )
        ( `    DATA lv_b TYPE i.` )
        ( `    DATA lv_c TYPE i.` )
        ( `    IF lv_a = 1.` )
        ( `    lv_b = 2.` )
        ( `    ELSEIF lv_a = 1.` )
        ( `    lv_c = 3.` )
        ( `    ENDIF.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_002.` )
        ( `    DATA lv_a TYPE i.` )
        ( `    DATA lv_b TYPE i.` )
        ( `    DATA lv_c TYPE i.` )
        ( `    IF lv_a = 1.` )
        ( `    lv_b = 2.` )
        ( `    ELSEIF lv_a = 2.` )
        ( `    lv_c = 3.` )
        ( `    ENDIF.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_003.` )
        ( `    DATA lv_type TYPE i.` )
        ( `    DATA lv_x TYPE i.` )
        ( `    CASE lv_type.` )
        ( `    WHEN 1.` )
        ( `    lv_x = 1.` )
        ( `    WHEN 1.` )
        ( `    lv_x = 2.` )
        ( `    ENDCASE.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_004.` )
        ( `    DATA lv_type TYPE i.` )
        ( `    DATA lv_x TYPE i.` )
        ( `    CASE lv_type.` )
        ( `    WHEN 1.` )
        ( `    lv_x = 1.` )
        ( `    WHEN 2.` )
        ( `    lv_x = 2.` )
        ( `    ENDCASE.` )
        ( `  ENDMETHOD.` )
        ( `ENDCLASS.` )
        ( `` ) ).

    zcl_skylint_test_runner=>run(
        io_check    = NEW zcl_skylint_check_016( )
        it_source   = lt_source
        it_expected = VALUE #( ( method = 'TEST_001'
                               code = zcl_skylint_check_016=>c_finding_codes-identical_condition line = 7 column = 4 )
                               ( method = 'TEST_002' )
                               ( method = 'TEST_003'
               code = zcl_skylint_check_016=>c_finding_codes-identical_condition line = 7 column = 4 )
                               ( method = 'TEST_004' ) ) ).
  ENDMETHOD.
ENDCLASS.
