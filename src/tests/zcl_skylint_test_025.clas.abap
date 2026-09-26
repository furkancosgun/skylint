CLASS zcl_skylint_test_025 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_025 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    IF lv_a EQ lv_b.
      RETURN.
    ENDIF.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    IF lv_a EQ lv_b. "#EC PREFER_OPERATORS
      RETURN.
    ENDIF.
  ENDMETHOD.

  METHOD valid_code.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    IF lv_a = lv_b.
      RETURN.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
