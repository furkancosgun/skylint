CLASS zcl_skylint_test_090 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_090 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lv_i TYPE i VALUE 0.
    lv_i = lv_i + 1.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lv_i TYPE i VALUE 0.
    lv_i = lv_i + 1. "#EC PREFER_CALC_ASSIGN
  ENDMETHOD.

  METHOD valid_code.
    DATA lv_i TYPE i VALUE 0.
    lv_i += 1.
  ENDMETHOD.
ENDCLASS.
