CLASS zcl_skylint_test_040 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_040 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lt_tab TYPE string_table.
    lt_tab = VALUE #( ).
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lt_tab TYPE string_table.
    lt_tab = VALUE #( ). "#EC SUPERFLUOUS_VAL
  ENDMETHOD.

  METHOD valid_code.
    DATA lt_tab TYPE string_table.
    CLEAR lt_tab.
    lt_tab = VALUE #( ( `item1` ) ).
  ENDMETHOD.
ENDCLASS.
