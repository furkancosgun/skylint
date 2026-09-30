CLASS zcl_skylint_test_062 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_062 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    TRY.
        TRY.
            RETURN.
          CATCH cx_static_check.
            RETURN.
        ENDTRY.
      CATCH cx_root.
        RETURN.
    ENDTRY.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    TRY.
        TRY. "#EC AVOID_NESTED_TRY
            RETURN.
          CATCH cx_static_check.
            RETURN.
        ENDTRY.
      CATCH cx_root.
        RETURN.
    ENDTRY.
  ENDMETHOD.

  METHOD valid_code.
    TRY.
        RETURN.
      CATCH cx_static_check.
        RETURN.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
