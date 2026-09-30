CLASS zcl_skylint_test_094 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_094 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lv_unused TYPE i.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lv_unused TYPE i. "#EC UNUSED_VAR
  ENDMETHOD.

  METHOD valid_code.
    DATA lv_used TYPE i.
    lv_used = 10.
  ENDMETHOD.
ENDCLASS.
