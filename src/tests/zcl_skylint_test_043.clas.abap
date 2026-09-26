CLASS zcl_skylint_test_043 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_043 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    CONSTANTS c_untyped VALUE 'X'.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    CONSTANTS c_untyped VALUE 'X'. "#EC FULLY_TYPED_CONST
  ENDMETHOD.

  METHOD valid_code.
    CONSTANTS c_typed TYPE c LENGTH 1 VALUE 'X'.
    CONSTANTS c_str TYPE string VALUE 'HELLO'.
  ENDMETHOD.
ENDCLASS.
