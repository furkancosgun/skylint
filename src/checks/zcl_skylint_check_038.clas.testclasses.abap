CLASS ltcl_check_038 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_check FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_038 IMPLEMENTATION.
  METHOD test_check.
    DATA lt_source TYPE string_table.

    lt_source = VALUE #(
        ( `CLASS zcl_skylint_test_038 DEFINITION` )
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
        ( `CLASS zcl_skylint_test_038 IMPLEMENTATION.` )
        ( `  METHOD test_001.` )
        ( `    DATA: BEGIN OF ls_src, a TYPE i, END OF ls_src.` )
        ( `    DATA: BEGIN OF ls_dst, a TYPE i, END OF ls_dst.` )
        ( `    MOVE-CORRESPONDING ls_src TO ls_dst.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_002.` )
        ( `    DATA: BEGIN OF ls_src, a TYPE i, END OF ls_src.` )
        ( `    DATA: BEGIN OF ls_dst, a TYPE i, END OF ls_dst.` )
        ( `    ls_dst = CORRESPONDING #( ls_src ).` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_003.` )
        ( `    DATA: BEGIN OF ls_a, b TYPE i, END OF ls_a.` )
        ( `    DATA: BEGIN OF ls_b, b TYPE i, END OF ls_b.` )
        ( `    MOVE-CORRESPONDING ls_a TO ls_b.` )
        ( `  ENDMETHOD.` )
        ( `` )
        ( `  METHOD test_004.` )
        ( `    DATA: BEGIN OF ls_a, b TYPE i, END OF ls_a.` )
        ( `    DATA: BEGIN OF ls_b, b TYPE i, END OF ls_b.` )
        ( `    ls_b = CORRESPONDING #( ls_a ).` )
        ( `  ENDMETHOD.` )
        ( `ENDCLASS.` ) ).

    zcl_skylint_test_runner=>run(
        io_check    = NEW zcl_skylint_check_038( )
        it_source   = lt_source
        it_expected = VALUE #(
                                      ( method = 'TEST_001'
               code = zcl_skylint_check_038=>c_finding_codes-prefer_corresponding line = 4 column = 4 )
                                      ( method = 'TEST_002' )
                                      ( method = 'TEST_003'
               code = zcl_skylint_check_038=>c_finding_codes-prefer_corresponding line = 4 column = 4 )
                                      ( method = 'TEST_004' ) ) ).
  ENDMETHOD.
ENDCLASS.
