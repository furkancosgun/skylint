CLASS zcl_skylint_test_053 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_053 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lv_a TYPE i VALUE 10.
    DATA lv_b LIKE lv_a.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lv_a TYPE i VALUE 10.
    DATA lv_b LIKE lv_a. "#EC AVOID_LIKE_TYPE
  ENDMETHOD.

  METHOD valid_code.
    DATA lv_a TYPE i VALUE 10.
    DATA lv_b TYPE i.
  ENDMETHOD.
ENDCLASS.
