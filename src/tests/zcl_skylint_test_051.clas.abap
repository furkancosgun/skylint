CLASS zcl_skylint_test_051 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.

ENDCLASS.


CLASS zcl_skylint_test_051 IMPLEMENTATION.

  METHOD without_pseudo_comments.
    sy-subrc = 0.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    sy-subrc = 0. "#EC AVOID_SY_MOD
  ENDMETHOD.

  METHOD valid_code.
    DATA lv_subrc TYPE i.
    lv_subrc = sy-subrc.
  ENDMETHOD.

ENDCLASS.
