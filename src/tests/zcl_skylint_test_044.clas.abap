CLASS zcl_skylint_test_044 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.


CLASS zcl_skylint_test_044 IMPLEMENTATION.
  METHOD test_001.
    DATA lv_msg TYPE string.
    DATA lv_lin TYPE i.
    DATA lv_wrd TYPE string.
    DATA lt_prog TYPE string_table.
    SYNTAX-CHECK FOR lt_prog MESSAGE lv_msg LINE lv_lin WORD lv_wrd.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_flag TYPE abap_bool.
    CHECK lv_flag = abap_true.
  ENDMETHOD.
ENDCLASS.

