CLASS zcl_skylint_test_007 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_007 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_c TYPE i.

    lv_a = lv_b = lv_c = 0.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.

    lv_a = lv_b = 1. "#EC ASSIGN_CHAIN
  ENDMETHOD.

  METHOD valid_code.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.

    lv_a = 1.
    lv_b = 2.
  ENDMETHOD.
ENDCLASS.
