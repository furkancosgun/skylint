CLASS zcl_skylint_test_021 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_021 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lv_val TYPE i VALUE 1.

    CASE lv_val.
      WHEN OTHERS.
        RETURN.
      WHEN 1.
        RETURN.
    ENDCASE.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lv_val TYPE i VALUE 1.

    CASE lv_val.
      WHEN OTHERS. "#EC WHEN_OTHERS_LAST
        RETURN.
      WHEN 1.
        RETURN.
    ENDCASE.
  ENDMETHOD.

  METHOD valid_code.
    DATA lv_val TYPE i VALUE 1.

    CASE lv_val.
      WHEN 1.
        RETURN.
      WHEN OTHERS.
        RETURN.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
