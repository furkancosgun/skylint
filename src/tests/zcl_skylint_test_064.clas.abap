CLASS zcl_skylint_test_064 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_064 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lt_tab TYPE string_table.
    DATA lv_line TYPE string VALUE 'abc'.
    APPEND lv_line TO lt_tab.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lt_tab TYPE string_table.
    DATA lv_line TYPE string VALUE 'abc'.
    APPEND lv_line TO lt_tab. "#EC PREFER_INSERT
  ENDMETHOD.

  METHOD valid_code.
    DATA lt_tab TYPE string_table.
    DATA lv_line TYPE string VALUE 'abc'.
    INSERT lv_line INTO TABLE lt_tab.
  ENDMETHOD.
ENDCLASS.
