CLASS ltcl_check_009 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_check FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_009 IMPLEMENTATION.
  METHOD test_check.
    DATA lt_source TYPE string_table.

    lt_source = VALUE #(
        ( `CLASS zcl_skylint_test_009 DEFINITION` )
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
        ( `CLASS zcl_skylint_test_009 IMPLEMENTATION.` )
        ( `  METHOD test_001.` )
        ( `    DATA lv_a TYPE string.` )
        ( `    DATA lv_b TYPE string.` )
        ( `    DATA lv_c TYPE string.` )
        ( `    CONCATENATE lv_a lv_b INTO lv_c.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_002.` )
        ( `    DATA lv_a TYPE string.` )
        ( `    DATA lv_b TYPE string.` )
        ( `    DATA lv_c TYPE string.` )
        ( `    lv_c = |{ lv_a }{ lv_b }|.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_003.` )
        ( `    DATA lv_a TYPE string.` )
        ( `    DATA lv_b TYPE string.` )
        ( `    DATA lv_c TYPE string.` )
        ( `    CONCATENATE lv_a lv_b INTO lv_c SEPARATED BY space.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_004.` )
        ( `    DATA lv_a TYPE string.` )
        ( `    DATA lv_b TYPE string.` )
        ( `    DATA lv_c TYPE string.` )
        ( `    lv_c = lv_a && lv_b.` )
        ( `  ENDMETHOD.` )
        ( `ENDCLASS.` ) ).

    zcl_skylint_test_runner=>run(
        io_check    = NEW zcl_skylint_check_009( )
        it_source   = lt_source
        it_expected = VALUE #(
            ( method = 'TEST_001' code = zcl_skylint_check_009=>c_finding_codes-prefer_template line = 5 column = 4 )
            ( method = 'TEST_002' )
            ( method = 'TEST_003' code = zcl_skylint_check_009=>c_finding_codes-prefer_template line = 5 column = 4 )
            ( method = 'TEST_004' ) ) ).
  ENDMETHOD.
ENDCLASS.
