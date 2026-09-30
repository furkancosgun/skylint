CLASS zcl_skylint_test_082 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_082 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    COMMIT WORK.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    COMMIT WORK. "#EC AVOID_COMMIT_WORK
  ENDMETHOD.

  METHOD valid_code.
    RETURN.
  ENDMETHOD.
ENDCLASS.
