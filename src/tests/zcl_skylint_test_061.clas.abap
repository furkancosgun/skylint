CLASS zcl_skylint_test_061 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    EXCEPTIONS
      failed.

    METHODS without_pseudo_comments EXCEPTIONS failed.
    METHODS with_pseudo_comments EXCEPTIONS failed.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_061 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    MESSAGE 'Error' TYPE 'E' RAISING failed.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    MESSAGE 'Error' TYPE 'E' RAISING failed. "#EC AVOID_MSG_RAISING
  ENDMETHOD.

  METHOD valid_code.
    MESSAGE 'Info message' TYPE 'I'.
  ENDMETHOD.
ENDCLASS.
