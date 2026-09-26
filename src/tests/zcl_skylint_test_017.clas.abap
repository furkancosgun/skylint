CLASS zcl_skylint_test_017 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_017 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    TRY.
      CATCH cx_root.
    ENDTRY.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    TRY.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.
  ENDMETHOD.

  METHOD valid_code.
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA lx_e TYPE REF TO cx_root.

    TRY.
      CATCH cx_root INTO lx_e.
        RETURN.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
