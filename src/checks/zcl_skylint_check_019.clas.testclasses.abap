CLASS ltcl_check_019 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_check FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_019 IMPLEMENTATION.
  METHOD test_check.
    DATA lt_source TYPE string_table.

    lt_source = VALUE #(
        ( `CLASS zcl_skylint_test_019 DEFINITION` )
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
        ( `CLASS zcl_skylint_test_019 IMPLEMENTATION.` )
        ( `  METHOD test_001.` )
        ( `    DATA lv_x TYPE i.` )
        ( `    DATA lv_type TYPE i.` )
        ( `    CASE lv_type.` )
        ( `    WHEN 1.` )
        ( `    lv_x = 1.` )
        ( `    ENDCASE.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_002.` )
        ( `    DATA lv_x TYPE i.` )
        ( `    DATA lv_type TYPE i.` )
        ( `    CASE lv_type.` )
        ( `    WHEN 1.` )
        ( `    lv_x = 1.` )
        ( `    WHEN 2.` )
        ( `    lv_x = 2.` )
        ( `    ENDCASE.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_003.` )
        ( `    DATA lv_x TYPE i.` )
        ( `    DATA lv_type TYPE i.` )
        ( `    CASE lv_type.` )
        ( `    WHEN OTHERS.` )
        ( `    lv_x = 1.` )
        ( `    ENDCASE.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_004.` )
        ( `    DATA lv_x TYPE i.` )
        ( `    DATA lv_type TYPE i.` )
        ( `    CASE lv_type.` )
        ( `    WHEN 1.` )
        ( `    lv_x = 1.` )
        ( `    WHEN 2.` )
        ( `    lv_x = 2.` )
        ( `    WHEN 3.` )
        ( `    lv_x = 3.` )
        ( `    ENDCASE.` )
        ( `  ENDMETHOD.` )
        ( `ENDCLASS.` )
        ( `` ) ).

    zcl_skylint_test_runner=>run(
        io_check    = NEW zcl_skylint_check_019( )
        it_source   = lt_source
        it_expected = VALUE #(
            ( method = 'TEST_001' code = zcl_skylint_check_019=>c_finding_codes-short_case line = 4 column = 4 )
            ( method = 'TEST_002' )
            ( method = 'TEST_003' code = zcl_skylint_check_019=>c_finding_codes-short_case line = 4 column = 4 )
            ( method = 'TEST_004' ) ) ).
  ENDMETHOD.
ENDCLASS.
