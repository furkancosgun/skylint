CLASS zcl_skylint_test_023 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments RAISING cx_static_check.
    METHODS with_pseudo_comments RAISING cx_static_check.
    METHODS valid_code RAISING cx_static_check.
ENDCLASS.


CLASS zcl_skylint_test_023 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    RAISE EXCEPTION TYPE cx_static_check.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    RAISE EXCEPTION TYPE cx_static_check. "#EC RAISE_EXC_NEW
  ENDMETHOD.

  METHOD valid_code.
    RAISE EXCEPTION NEW cx_static_check( ).
  ENDMETHOD.
ENDCLASS.
