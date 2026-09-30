CLASS zcl_skylint_test_020 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_020 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lv_val TYPE i.
    IF 1 = lv_val.
      RETURN.
    ENDIF.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lv_val TYPE i.
    IF 1 = lv_val. "#EC NO_YODA_CONDITIONS
      RETURN.
    ENDIF.
  ENDMETHOD.

  METHOD valid_code.
    DATA lv_val TYPE i.
    IF lv_val = 1.
      RETURN.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
