CLASS zcl_skylint_test_006 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    DATA mv_value TYPE i.

    METHODS helper.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_006 IMPLEMENTATION.
  METHOD helper.
  ENDMETHOD.

  METHOD without_pseudo_comments.
    me->helper( ).
    me->mv_value = 10.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    me->helper( ). "#EC AVOID_ME
  ENDMETHOD.

  METHOD valid_code.
    helper( ).
    mv_value = 10.
  ENDMETHOD.
ENDCLASS.
