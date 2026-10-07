CLASS ltcl_check_026 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_check FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_026 IMPLEMENTATION.
  METHOD test_check.
    DATA lt_source TYPE string_table.

    lt_source = VALUE #(
        ( `CLASS zcl_skylint_test_026 DEFINITION` )
        ( `  PUBLIC FINAL` )
        ( `  CREATE PUBLIC.` )
        ( `` )
        ( `  PUBLIC SECTION.` )
        ( `    CLASS-METHODS do_work.` )
        ( `    METHODS test_001.` )
        ( `    METHODS test_002.` )
        ( `    METHODS test_003.` )
        ( `    METHODS test_004.` )
        ( `ENDCLASS.` )
        ( `` )
        ( `CLASS zcl_skylint_test_026 IMPLEMENTATION.` )
        ( `  METHOD do_work.` )
        ( `    RETURN.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_001.` )
        ( `    DATA lo_obj TYPE REF TO zcl_skylint_test_026.` )
        ( `    lo_obj->do_work( ).` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_002.` )
        ( `    zcl_skylint_test_026=>do_work( ).` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_003.` )
        ( `    DATA lo_obj TYPE REF TO zcl_skylint_test_026.` )
        ( `    CALL METHOD lo_obj->do_work.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_004.` )
        ( `    CALL METHOD zcl_skylint_test_026=>do_work.` )
        ( `  ENDMETHOD.` )
        ( `ENDCLASS.` ) ).

    zcl_skylint_test_runner=>run(
        io_check    = NEW zcl_skylint_check_026( )
        it_source   = lt_source
        it_expected = VALUE #(
            ( method = 'TEST_001'
               code = zcl_skylint_check_026=>c_finding_codes-static_call_via_instance line = 3 column = 4 )
            ( method = 'TEST_002' )
            ( method = 'TEST_003'
               code = zcl_skylint_check_026=>c_finding_codes-static_call_via_instance line = 3 column = 4 )
            ( method = 'TEST_004' ) ) ).
  ENDMETHOD.
ENDCLASS.
