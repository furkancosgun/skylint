CLASS zcl_skylint_test_029 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS helper_method
      RETURNING
        VALUE(rv_res) TYPE i.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_029 IMPLEMENTATION.
  METHOD helper_method.
    rv_res = 42.
  ENDMETHOD.

  METHOD without_pseudo_comments.
    DATA lv_result TYPE i.
    helper_method( RECEIVING rv_res = lv_result ).
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lv_result TYPE i.
    helper_method( RECEIVING rv_res = lv_result ). "#EC RECEIVING_USAGE
  ENDMETHOD.

  METHOD valid_code.
    DATA lv_result TYPE i.
    lv_result = helper_method( ).
  ENDMETHOD.
ENDCLASS.
