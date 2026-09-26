CLASS zcl_skylint_test_032 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_032 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    MOVE lv_a TO lv_b.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    MOVE lv_a TO lv_b. "#EC DEPRECATED_KEY
  ENDMETHOD.

  METHOD valid_code.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    lv_b = lv_a.
  ENDMETHOD.
ENDCLASS.
