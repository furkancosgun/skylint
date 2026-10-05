CLASS zcl_skylint_test_013 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
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
ENDCLASS.

