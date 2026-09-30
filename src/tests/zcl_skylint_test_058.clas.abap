CLASS zcl_skylint_test_058 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.

ENDCLASS.


CLASS zcl_skylint_test_058 IMPLEMENTATION.

  METHOD without_pseudo_comments.
    RAISE SHORTDUMP TYPE cx_sy_create_error
      EXPORTING
        textid = cx_sy_create_error=>cx_sy_create_error.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    RAISE SHORTDUMP TYPE cx_sy_create_error "#EC AVOID_SHORTDUMP
      EXPORTING
        textid = cx_sy_create_error=>cx_sy_create_error.
  ENDMETHOD.

  METHOD valid_code.
    DATA lx_err TYPE REF TO cx_sy_create_error.
    CREATE OBJECT lx_err.
    RAISE EXCEPTION lx_err.
  ENDMETHOD.

ENDCLASS.
