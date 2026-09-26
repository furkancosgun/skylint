CLASS zcl_skylint_test_005 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_005 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lv_val TYPE i.
    DATA lo_obj TYPE REF TO zcl_skylint_test_005.

    IF NOT lv_val IS INITIAL.
      lv_val = 1.
    ENDIF.

    IF NOT lo_obj IS BOUND.
      CREATE OBJECT lo_obj.
    ENDIF.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lv_val TYPE i.

    IF NOT lv_val IS INITIAL. "#EC PREFER_IS_NOT
      lv_val = 1.
    ENDIF.
  ENDMETHOD.

  METHOD valid_code.
    DATA lv_val TYPE i.

    IF lv_val IS NOT INITIAL.
      lv_val = 2.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
