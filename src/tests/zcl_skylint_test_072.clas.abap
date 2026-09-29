CLASS zcl_skylint_test_072 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments
      CHANGING cv_unmodified TYPE i.

    METHODS with_pseudo_comments
      CHANGING cv_unmodified TYPE i. "#EC UNMODIFIED_CHANGING

    METHODS valid_code
      IMPORTING iv_val TYPE i.
ENDCLASS.


CLASS zcl_skylint_test_072 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lv_val TYPE i.
    lv_val = cv_unmodified.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lv_val TYPE i.
    lv_val = cv_unmodified.
  ENDMETHOD.

  METHOD valid_code.
    DATA lv_val TYPE i.
    lv_val = iv_val.
  ENDMETHOD.
ENDCLASS.
