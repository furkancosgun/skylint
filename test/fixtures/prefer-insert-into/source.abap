CLASS zcl_test_prefer_insert_into DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.


CLASS zcl_test_prefer_insert_into IMPLEMENTATION.
  METHOD test_001.
    DATA lt_tab TYPE string_table.
    DATA ls_row TYPE string.
    APPEND ls_row TO lt_tab.
  ENDMETHOD.

  METHOD test_002.
    DATA lt_tab TYPE string_table.
    DATA ls_row TYPE string.
    INSERT ls_row INTO TABLE lt_tab.
  ENDMETHOD.

  METHOD test_003.
    DATA lt_tab TYPE string_table.
    APPEND INITIAL LINE TO lt_tab.
  ENDMETHOD.

  METHOD test_004.
    DATA lt_tab TYPE string_table.
    DATA lv_lin TYPE i.
    lv_lin = lines( lt_tab ).
  ENDMETHOD.
ENDCLASS.

