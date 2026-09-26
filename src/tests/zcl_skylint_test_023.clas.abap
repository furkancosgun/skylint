CLASS zcl_skylint_test_023 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_023 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lv_val TYPE i.

    CASE lv_val.
      WHEN 1.
        RETURN.
    ENDCASE.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lv_val TYPE i.

    CASE lv_val. "#EC SHORT_CASE
      WHEN 1.
        RETURN.
    ENDCASE.
  ENDMETHOD.

  METHOD valid_code.
    DATA lv_val TYPE i.

    CASE lv_val.
      WHEN 1.
        RETURN.
      WHEN 2.
        RETURN.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
