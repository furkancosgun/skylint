CLASS zcl_skylint_test_042 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_042 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lv_val TYPE string.
    lv_val = lv_val.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lv_val TYPE string.
    lv_val = lv_val. "#EC IDENTICAL_MOVE
  ENDMETHOD.

  METHOD valid_code.
    DATA lv_val TYPE string.
    DATA lv_src TYPE string.
    lv_val = lv_src.
  ENDMETHOD.
ENDCLASS.
