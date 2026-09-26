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
    DATA lv_val TYPE i VALUE 10.
    cl_abap_unit_assert=>assert_equals(
        act = lv_val
        exp = lv_val ).
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lv_val TYPE i VALUE 10.
    cl_abap_unit_assert=>assert_equals(
        act = lv_val
        exp = lv_val ). "#EC UT_ASSERT
  ENDMETHOD.

  METHOD valid_code.
    DATA lv_val TYPE i VALUE 10.
    cl_abap_unit_assert=>assert_equals(
        act = lv_val
        exp = 20 ).
  ENDMETHOD.
ENDCLASS.
