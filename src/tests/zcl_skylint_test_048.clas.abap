CLASS zcl_skylint_test_048 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.

ENDCLASS.


CLASS zcl_skylint_test_048 IMPLEMENTATION.

  METHOD without_pseudo_comments.
    DATA lv_a TYPE i.
    lv_a = 1.
    lv_a = 2.
    lv_a = 3.
    lv_a = 4.
    lv_a = 5.
    lv_a = 6.
  ENDMETHOD.

  METHOD with_pseudo_comments. "#EC METHOD_LENGTH
    DATA lv_a TYPE i.
    lv_a = 1.
    lv_a = 2.
    lv_a = 3.
    lv_a = 4.
    lv_a = 5.
    lv_a = 6.
  ENDMETHOD.

  METHOD valid_code.
    DATA lv_a TYPE i.
    lv_a = 1.
  ENDMETHOD.

ENDCLASS.
