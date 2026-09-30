CLASS zcl_skylint_test_011 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_011 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lt_tab TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
    READ TABLE lt_tab INDEX 1 TRANSPORTING NO FIELDS.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lt_tab TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
    READ TABLE lt_tab INDEX 1 TRANSPORTING NO FIELDS. "#EC PREFER_LINE_EXISTS
  ENDMETHOD.

  METHOD valid_code.
    DATA lt_tab TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
    DATA lv_row TYPE string.
    READ TABLE lt_tab INTO lv_row INDEX 1.
    READ TABLE lt_tab WITH KEY table_line = 'A' BINARY SEARCH TRANSPORTING NO FIELDS.
    IF line_exists( lt_tab[ 1 ] ).
      RETURN.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
