CLASS zcl_skylint_test_072 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    DATA mv_attr1 TYPE i.
    DATA mv_attr2 TYPE i.
    DATA mv_attr3 TYPE i.
    DATA mv_attr4 TYPE i.
    DATA mv_attr5 TYPE i.
    DATA mv_attr6 TYPE i.

    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_072 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    " Implementation
  ENDMETHOD.

  METHOD with_pseudo_comments.
    " Implementation
  ENDMETHOD.

  METHOD valid_code.
    " Implementation
  ENDMETHOD.
ENDCLASS.
