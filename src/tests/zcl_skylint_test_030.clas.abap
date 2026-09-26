CLASS zcl_skylint_test_030 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS my_static_method.

    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_030 IMPLEMENTATION.
  METHOD my_static_method.
    RETURN.
  ENDMETHOD.

  METHOD without_pseudo_comments.
    me->my_static_method( ).
  ENDMETHOD.

  METHOD with_pseudo_comments.
    me->my_static_method( ). "#EC STATIC_CALL
  ENDMETHOD.

  METHOD valid_code.
    zcl_skylint_test_030=>my_static_method( ).
  ENDMETHOD.
ENDCLASS.
