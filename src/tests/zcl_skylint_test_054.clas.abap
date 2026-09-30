CLASS zcl_skylint_test_054 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_054 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lt_tab TYPE string_table.
    DATA lv_line TYPE string.
    LOOP AT lt_tab INTO lv_line.
      lv_line = 'test'.
    ENDLOOP.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lt_tab TYPE string_table.
    DATA lv_line TYPE string.
    LOOP AT lt_tab INTO lv_line. "#EC CONSTRUCTOR_LOGIC
      lv_line = 'test'.
    ENDLOOP.
  ENDMETHOD.

  METHOD valid_code.
    DATA lv_name TYPE string.
    lv_name = 'test'.
  ENDMETHOD.
ENDCLASS.
