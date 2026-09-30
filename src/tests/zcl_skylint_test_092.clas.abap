CLASS zcl_skylint_test_092 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_092 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lv_valid TYPE abap_bool VALUE abap_true.
    IF lv_valid = abap_true.
      lv_valid = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lv_valid TYPE abap_bool VALUE abap_true.
    IF lv_valid = abap_true. "#EC GUARD_IN_METHOD
      lv_valid = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD valid_code.
    DATA lv_valid TYPE abap_bool VALUE abap_true.
    IF lv_valid = abap_false.
      RETURN.
    ENDIF.
    lv_valid = abap_false.
  ENDMETHOD.
ENDCLASS.
