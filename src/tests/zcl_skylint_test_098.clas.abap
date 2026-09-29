CLASS zcl_skylint_test_098 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_098 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lv_ok TYPE abap_bool VALUE abap_true.
    ASSERT lv_ok = abap_true.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lv_ok TYPE abap_bool VALUE abap_true.
    ASSERT lv_ok = abap_true. "#EC PROD_ASSERT
  ENDMETHOD.

  METHOD valid_code.
    DATA lv_ok TYPE abap_bool VALUE abap_true.
    IF lv_ok = abap_false.
      RAISE EXCEPTION TYPE cx_static_check.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
