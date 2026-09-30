CLASS zcl_skylint_test_095 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_095 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lv_val TYPE i.
    CLEAR lv_val.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lv_val TYPE i.
    CLEAR lv_val. "#EC NEEDLESS_CLEAR
  ENDMETHOD.

  METHOD valid_code.
    DATA lv_val TYPE i.
    lv_val = 5.
    lv_val = lv_val + 2.
  ENDMETHOD.
ENDCLASS.
