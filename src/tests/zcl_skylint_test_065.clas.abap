CLASS zcl_skylint_test_065 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_065 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    PERFORM my_subroutine IF FOUND.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    PERFORM my_subroutine IF FOUND. "#EC AVOID_FORM_ROUTINE
  ENDMETHOD.

  METHOD valid_code.
    without_pseudo_comments( ).
  ENDMETHOD.
ENDCLASS.
