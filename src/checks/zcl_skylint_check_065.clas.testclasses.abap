CLASS ltcl_check_065 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_check FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_065 IMPLEMENTATION.
  METHOD test_check.
    DATA lt_source TYPE string_table.

    lt_source = VALUE #(
        ( `CLASS zcl_skylint_test_065 DEFINITION` )
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
        ( `CLASS zcl_skylint_test_065 IMPLEMENTATION.` )
        ( `  METHOD test_001.` )
        ( `    PERFORM my_form IN PROGRAM (sy-repid) IF FOUND.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_002.` )
        ( `    DATA lo_obj TYPE REF TO zcl_skylint_test_065.` )
        ( `    lo_obj->test_002( ).` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_003.` )
        ( `    PERFORM my_other_form.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_004.` )
        ( `    DATA lv_val TYPE i.` )
        ( `    lv_val = 1.` )
        ( `  ENDMETHOD.` )
        ( `ENDCLASS.` )
        ( `` )
        ( `FORM my_other_form.` )
        ( `ENDFORM.` ) ).

    zcl_skylint_test_runner=>run(
        io_check    = NEW zcl_skylint_check_065( )
        it_source   = lt_source
        it_expected = VALUE #(
            ( method = 'TEST_001' code = zcl_skylint_check_065=>c_finding_codes-avoid_form line = 2 column = 4 )
            ( method = 'TEST_002' )
            ( method = 'TEST_003' code = zcl_skylint_check_065=>c_finding_codes-avoid_form line = 2 column = 4 )
            ( method = 'TEST_004' ) ) ).
  ENDMETHOD.
ENDCLASS.
