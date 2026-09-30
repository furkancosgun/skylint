CLASS zcl_skylint_test_060 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_060 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lx_root TYPE REF TO cx_root.
    TRY.
        RETURN.
      CATCH cx_root INTO lx_root.
        RETURN.
    ENDTRY.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lx_root TYPE REF TO cx_root.
    TRY.
        RETURN.
      CATCH cx_root INTO lx_root. "#EC AVOID_CX_ROOT
        RETURN.
    ENDTRY.
  ENDMETHOD.

  METHOD valid_code.
    DATA lx_error TYPE REF TO cx_static_check.
    TRY.
        RETURN.
      CATCH cx_static_check INTO lx_error.
        RETURN.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
