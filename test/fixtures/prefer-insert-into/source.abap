CLASS zcl_test_prefer_insert_into DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
    METHODS test_006.
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

  METHOD test_005.
    DATA lt_tab TYPE string_table.
    APPEND VALUE #( ) TO lt_tab.
  ENDMETHOD.

  METHOD test_006.
    TYPES: BEGIN OF ty_item,
             name TYPE string,
           END OF ty_item.
    DATA lt_items TYPE STANDARD TABLE OF ty_item WITH EMPTY KEY.
    APPEND VALUE #( name = '[test' ) TO lt_items.
  ENDMETHOD.
ENDCLASS.

