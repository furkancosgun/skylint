CLASS zcl_skylint_test_pref_tab_expr DEFINITION
  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
    METHODS test_006.
ENDCLASS.

CLASS zcl_skylint_test_pref_tab_expr IMPLEMENTATION.

  METHOD test_001.
    DATA lt_items TYPE string_table.
    DATA ls_item  TYPE string.

    READ TABLE lt_items INTO ls_item INDEX 1.
  ENDMETHOD.

  METHOD test_002.
    DATA lt_items TYPE string_table.
    FIELD-SYMBOLS <ls_item> TYPE string.

    READ TABLE lt_items ASSIGNING <ls_item> INDEX 2.
  ENDMETHOD.

  METHOD test_003.
    DATA lt_items TYPE string_table.

    " Compliant: TRANSPORTING NO FIELDS handled by prefer-line-exists
    READ TABLE lt_items TRANSPORTING NO FIELDS WITH KEY table_line = 'A'.
  ENDMETHOD.

  METHOD test_004.
    DATA lt_items TYPE string_table.
    DATA ls_item  TYPE string.

    " Compliant: BINARY SEARCH requires sorted table or explicit sort
    READ TABLE lt_items INTO ls_item WITH KEY table_line = 'A' BINARY SEARCH.
  ENDMETHOD.

  METHOD test_005.
    DATA lt_items TYPE string_table.
    DATA ls_item  TYPE string.

    " Suppressed via pseudo comment
    READ TABLE lt_items INTO ls_item INDEX 1. "#EC PREF_TAB_EXPR
  ENDMETHOD.

  METHOD test_006.
    DATA lt_items TYPE string_table.
    DATA ls_item  TYPE string.

    " Compliant: already using table expression
    ls_item = VALUE #( lt_items[ 1 ] OPTIONAL ).
  ENDMETHOD.

ENDCLASS.
