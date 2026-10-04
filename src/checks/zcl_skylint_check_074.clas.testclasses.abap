CLASS ltcl_check_074 DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_finding FOR TESTING RAISING cx_static_check.
    METHODS test_clean   FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_check_074 IMPLEMENTATION.
  METHOD test_finding.
    zcl_skylint_test_util=>assert_findings(
        io_check    = NEW zcl_skylint_check_074( )
        it_source   = VALUE #( ( `LOOP AT lt_tab INTO ls_row.` )
                               ( `IF ls_row-flag = abap_true.` )
                               ( `ls_val = 1.` )
                               ( `ENDIF.` )
                               ( `ENDLOOP.` ) )
        it_expected = VALUE #( ( line = 3
                                 code = zcl_skylint_check_074=>c_finding_codes-guard_loop ) ) ).
  ENDMETHOD.

  METHOD test_clean.
    zcl_skylint_test_util=>assert_no_findings( io_check  = NEW zcl_skylint_check_074( )
                                               it_source = VALUE #( ( `LOOP AT lt_tab INTO ls_row.` )
                                                                    ( `ls_val = 1.` )
                                                                    ( `ENDLOOP.` ) ) ).
  ENDMETHOD.
ENDCLASS.

*"* --- Local Test Fixture Class ---
CLASS lcl_test_code DEFINITION FINAL.
  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_row,
        flag TYPE abap_bool,
      END OF ty_row.

    METHODS test_with_finding.
    METHODS test_clean_code.
ENDCLASS.

CLASS lcl_test_code IMPLEMENTATION.
  METHOD test_with_finding.
    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.
    DATA ls_row TYPE ty_row.
    DATA ls_val TYPE i.
    LOOP AT lt_tab INTO ls_row.
      IF ls_row-flag = abap_true.
        ls_val = 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_clean_code.
    DATA lt_tab TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.
    DATA ls_row TYPE ty_row.
    DATA ls_val TYPE i.
    LOOP AT lt_tab INTO ls_row.
      ls_val = 1.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
