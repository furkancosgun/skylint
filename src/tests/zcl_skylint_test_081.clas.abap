CLASS zcl_skylint_test_081 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_081 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    TRY.
        RETURN.
      CATCH cx_static_check.
        RETURN.
    ENDTRY.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    TRY. "#EC MISSING_CLEANUP
        RETURN.
      CATCH cx_static_check.
        RETURN.
    ENDTRY.
  ENDMETHOD.

  METHOD valid_code.
    TRY.
        RETURN.
      CLEANUP.
        RETURN.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
