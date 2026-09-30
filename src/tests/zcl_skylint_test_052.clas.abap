CLASS zcl_skylint_test_052 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_052 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lt_tab TYPE string_table.
    DATA lv_line TYPE string.
    LOOP AT lt_tab INTO lv_line.
      AT FIRST.
        lv_line = 'first'.
      ENDAT.
      SUM.
    ENDLOOP.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lt_tab TYPE string_table.
    DATA lv_line TYPE string.
    LOOP AT lt_tab INTO lv_line.
      AT FIRST. "#EC AVOID_LOOP_CTRL
        lv_line = 'first'.
      ENDAT.
      SUM. "#EC AVOID_LOOP_CTRL
    ENDLOOP.
  ENDMETHOD.

  METHOD valid_code.
    DATA lt_tab TYPE string_table.
    DATA lv_line TYPE string.
    LOOP AT lt_tab INTO lv_line.
      IF sy-tabix = 1.
        lv_line = 'first'.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
