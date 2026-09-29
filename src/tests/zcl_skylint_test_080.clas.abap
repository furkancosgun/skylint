CLASS zcl_skylint_test_080 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_080 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    RAISE EXCEPTION TYPE cx_sy_zerodivide.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    RAISE EXCEPTION TYPE cx_sy_zerodivide. "#EC AVOID_RAISE_SY_EXC
  ENDMETHOD.

  METHOD valid_code.
    RAISE EXCEPTION TYPE cx_static_check.
  ENDMETHOD.
ENDCLASS.
