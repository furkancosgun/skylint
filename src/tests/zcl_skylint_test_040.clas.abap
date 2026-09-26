CLASS zcl_skylint_test_040 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_040 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    IF 1 = 1.
      DATA(lv_val) = 1.
    ENDIF.
    lv_val = 2.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    IF 1 = 1.
      DATA(lv_val) = 1.
    ENDIF.
    lv_val = 2. "#EC SCOPE_OF_VAR
  ENDMETHOD.

  METHOD valid_code.
    DATA lv_val TYPE i.
    IF 1 = 1.
      lv_val = 1.
    ENDIF.
    lv_val = 2.
  ENDMETHOD.
ENDCLASS.
