CLASS zcl_skylint_test_079 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_079 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    TRY.
        RETURN.
      CATCH cx_static_check.
    ENDTRY.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    TRY.
        RETURN.
      CATCH cx_static_check. "#EC EMPTY_CATCH_BLOCK
    ENDTRY.
  ENDMETHOD.

  METHOD valid_code.
    DATA lv_handled TYPE abap_bool.
    TRY.
        RETURN.
      CATCH cx_static_check.
        lv_handled = abap_true.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
