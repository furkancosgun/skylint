CLASS ltcl_check_067 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_check FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_067 IMPLEMENTATION.
  METHOD test_check.
    DATA lt_source TYPE string_table.

    lt_source = VALUE #(
        ( `CLASS zcl_beh DEFINITION INHERITING FROM cl_abap_behavior_handler.` )
        ( `  PUBLIC SECTION.` )
        ( `    METHODS do_commit.` )
        ( `    METHODS clean_it.` )
        ( `ENDCLASS.` )
        ( `CLASS zcl_beh IMPLEMENTATION.` )
        ( `  METHOD do_commit.` )
        ( `    COMMIT WORK.` )
        ( `  ENDMETHOD.` )
        ( `  METHOD clean_it.` )
        ( `    RETURN.` )
        ( `  ENDMETHOD.` )
        ( `ENDCLASS.` )
        ( `CLASS zcl_plain DEFINITION.` )
        ( `  PUBLIC SECTION.` )
        ( `    METHODS do_plain.` )
        ( `ENDCLASS.` )
        ( `CLASS zcl_plain IMPLEMENTATION.` )
        ( `  METHOD do_plain.` )
        ( `    COMMIT WORK.` )
        ( `  ENDMETHOD.` )
        ( `ENDCLASS.` ) ).

    zcl_skylint_test_runner=>run(
        io_check    = NEW zcl_skylint_check_067( )
        it_source   = lt_source
        it_expected = VALUE #(
            ( method = 'DO_COMMIT'
              code   = zcl_skylint_check_067=>c_finding_codes-no_commit
              line   = 2
              column = 4 )
            ( method = 'DO_PLAIN' ) ) ).
  ENDMETHOD.
ENDCLASS.
