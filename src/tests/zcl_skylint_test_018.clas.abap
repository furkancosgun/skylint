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
    DATA lv_x TYPE i.
    RETURN.
    lv_x = 1.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lv_x TYPE i.
    RETURN.
    lv_x = 1. "#EC UNREACHABLE_CODE
  ENDMETHOD.

  METHOD valid_code.
    DATA lv_x TYPE i.
    IF lv_x = 0.
      RETURN.
    ELSE.
      lv_x = 2.
    ENDIF.
    lv_x = 3.
  ENDMETHOD.
ENDCLASS.
