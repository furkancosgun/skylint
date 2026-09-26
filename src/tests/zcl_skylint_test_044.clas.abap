CLASS zcl_skylint_test_044 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS helper
      IMPORTING
        iv_val TYPE string.

    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_044 IMPLEMENTATION.
  METHOD helper.
  ENDMETHOD.

  METHOD without_pseudo_comments.
    helper( iv_val = 'TEST' ).
  ENDMETHOD.

  METHOD with_pseudo_comments.
    helper( iv_val = 'TEST' ). "#EC OMIT_PARAM_NAME
  ENDMETHOD.

  METHOD valid_code.
    helper( 'TEST' ).
  ENDMETHOD.
ENDCLASS.
