CLASS ltcl_check_027 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_check FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_027 IMPLEMENTATION.
  METHOD test_check.
    DATA lt_source TYPE string_table.

    lt_source = VALUE #(
        ( `CLASS lcl_mutable DEFINITION.` )
        ( `  PUBLIC SECTION.` )
        ( `    DATA mv_attr TYPE i.` )
        ( `ENDCLASS.` )
        ( `CLASS lcl_mutable IMPLEMENTATION.` )
        ( `ENDCLASS.` )
        ( `` )
        ( `CLASS lcl_clean DEFINITION.` )
        ( `  PUBLIC SECTION.` )
        ( `    DATA mv_attr TYPE i READ-ONLY.` )
        ( `ENDCLASS.` )
        ( `CLASS lcl_clean IMPLEMENTATION.` )
        ( `ENDCLASS.` )
        ( `` )
        ( `CLASS lcl_extra_bad DEFINITION.` )
        ( `  PUBLIC SECTION.` )
        ( `    DATA mv_extra TYPE string.` )
        ( `ENDCLASS.` )
        ( `CLASS lcl_extra_bad IMPLEMENTATION.` )
        ( `ENDCLASS.` )
        ( `` )
        ( `CLASS lcl_extra_clean DEFINITION.` )
        ( `  PRIVATE SECTION.` )
        ( `    DATA mv_priv TYPE i.` )
        ( `ENDCLASS.` )
        ( `CLASS lcl_extra_clean IMPLEMENTATION.` )
        ( `ENDCLASS.` )
        ( `` )
        ( `CLASS zcl_skylint_test_027 DEFINITION` )
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
        ( `CLASS zcl_skylint_test_027 IMPLEMENTATION.` )
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
        ( `    RETURN.` )
        ( `  ENDMETHOD.` )
        ( `ENDCLASS.` ) ).

    zcl_skylint_test_runner=>run(
        io_check    = NEW zcl_skylint_check_027( )
        it_source   = lt_source
        it_expected = VALUE #(
            ( method = 'TEST_001' code = zcl_skylint_check_027=>c_finding_codes-public_attribute line = 3 column = 4 )
            ( method = 'TEST_002' )
            ( method = 'TEST_003' code = zcl_skylint_check_027=>c_finding_codes-public_attribute line = 3 column = 4 )
            ( method = 'TEST_004' ) ) ).
  ENDMETHOD.
ENDCLASS.
