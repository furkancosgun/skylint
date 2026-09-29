CLASS zcl_skylint_test_096 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_096 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lt_data TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    DATA lv_val TYPE i.

    LOOP AT lt_data INTO lv_val.
      IF lv_val > 0.
        lv_val = lv_val * 2.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lt_data TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    DATA lv_val TYPE i.

    LOOP AT lt_data INTO lv_val.
      IF lv_val > 0. "#EC GUARD_IN_LOOP
        lv_val = lv_val * 2.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD valid_code.
    DATA lt_data TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    DATA lv_val TYPE i.

    LOOP AT lt_data INTO lv_val.
      IF lv_val <= 0.
        CONTINUE.
      ENDIF.
      lv_val = lv_val * 2.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
