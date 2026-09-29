CLASS zcl_skylint_test_102 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_102 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA: lv_val TYPE i.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA: lv_val TYPE i. "#EC SINGLE_CHAIN
  ENDMETHOD.

  METHOD valid_code.
    DATA lv_val TYPE i.
  ENDMETHOD.
ENDCLASS.
