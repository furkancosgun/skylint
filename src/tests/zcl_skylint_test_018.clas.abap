CLASS zcl_skylint_test_018 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_018 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lv_a TYPE i.
    lv_a = 1.
  ENDMETHOD.

  METHOD with_pseudo_comments. "#EC MISSING_ASSERT
    DATA lv_a TYPE i.
    lv_a = 1.
  ENDMETHOD.

  METHOD valid_code.
    cl_abap_unit_assert=>assert_equals(
        act = 1
        exp = 1 ).
  ENDMETHOD.
ENDCLASS.
