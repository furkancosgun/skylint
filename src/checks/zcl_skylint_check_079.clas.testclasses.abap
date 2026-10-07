CLASS ltcl_check_079 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_check FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_079 IMPLEMENTATION.
  METHOD test_check.
    DATA lt_source TYPE string_table.

    lt_source = VALUE #(
        ( `CLASS lcl_bad DEFINITION.` )
        ( `  PUBLIC SECTION.` )
        ( `    METHODS meth_escaped IMPORTING !iv_param TYPE i.` )
        ( `ENDCLASS.` )
        ( `CLASS lcl_bad IMPLEMENTATION.` )
        ( `  METHOD meth_escaped.` )
        ( `    RETURN.` )
        ( `  ENDMETHOD.` )
        ( `ENDCLASS.` )
        ( `` )
        ( `CLASS lcl_clean DEFINITION.` )
        ( `  PUBLIC SECTION.` )
        ( `    METHODS meth_clean IMPORTING iv_param TYPE i.` )
        ( `ENDCLASS.` )
        ( `CLASS lcl_clean IMPLEMENTATION.` )
        ( `  METHOD meth_clean.` )
        ( `    RETURN.` )
        ( `  ENDMETHOD.` )
        ( `ENDCLASS.` )
        ( `` )
        ( `CLASS zcl_skylint_test_079 DEFINITION` )
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
        ( `CLASS zcl_skylint_test_079 IMPLEMENTATION.` )
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
        io_check    = NEW zcl_skylint_check_079( )
        it_source   = lt_source
        it_expected = VALUE #(
            ( method = 'TEST_001' code = zcl_skylint_check_079=>c_finding_codes-param_escape line = 3 column = 4 )
            ( method = 'TEST_002' )
            ( method = 'TEST_003' code = zcl_skylint_check_079=>c_finding_codes-param_escape line = 3 column = 4 )
            ( method = 'TEST_004' ) ) ).
  ENDMETHOD.
ENDCLASS.
