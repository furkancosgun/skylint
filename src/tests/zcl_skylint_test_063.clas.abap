CLASS zcl_skylint_test_063 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_063 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lt_tab TYPE string_table.
    DATA lv_line TYPE string.
    READ TABLE lt_tab INTO lv_line INDEX 1.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lt_tab TYPE string_table.
    DATA lv_line TYPE string.
    READ TABLE lt_tab INTO lv_line INDEX 1. "#EC TABLE_EXPR
  ENDMETHOD.

  METHOD valid_code.
    DATA lt_tab TYPE string_table.
    DATA lv_line TYPE string.
    IF line_exists( lt_tab[ 1 ] ).
      lv_line = lt_tab[ 1 ].
    ENDIF.
  ENDMETHOD.
ENDCLASS.
