CLASS zcl_skylint_test_013 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.


CLASS zcl_skylint_test_013 IMPLEMENTATION.
  METHOD test_001.
    DATA lv_flag TYPE abap_bool.
    DATA lt_tab TYPE string_table.
    DATA ls_row TYPE string.
    LOOP AT lt_tab INTO ls_row.
    CHECK lv_flag.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_flag TYPE abap_bool.
    CHECK lv_flag.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_flag TYPE abap_bool.
    DO 5 TIMES.
      CHECK lv_flag = abap_true.
    ENDDO.
  ENDMETHOD.

  METHOD test_004.
    DATA lt_tab TYPE string_table.
    DATA ls_row TYPE string.
    LOOP AT lt_tab INTO ls_row.
      IF ls_row IS INITIAL.
        CONTINUE.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

