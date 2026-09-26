CLASS zcl_skylint_test_007 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS helper
      IMPORTING iv_val TYPE i.

    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_007 IMPLEMENTATION.
  METHOD helper.
  ENDMETHOD.

  METHOD without_pseudo_comments.
    helper( iv_val = 1 ).
  ENDMETHOD.

  METHOD with_pseudo_comments.
    helper( iv_val = 1 ). "#EC OMIT_EXPORTING
  ENDMETHOD.

  METHOD valid_code.
    helper( iv_val = 1 ).
    helper( 1 ).
  ENDMETHOD.
ENDCLASS.
