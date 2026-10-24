CLASS zcl_skylint_test_mod_loop DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_006.
    METHODS test_007.
    METHODS test_008.
    METHODS test_009.
    METHODS test_011.
    METHODS test_012.

ENDCLASS.


CLASS zcl_skylint_test_mod_loop IMPLEMENTATION.
  METHOD test_001.
    DATA lt_items TYPE string_table.
    LOOP AT lt_items INTO DATA(lv_item).
      APPEND lv_item TO lt_items.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_002.
    DATA lt_items TYPE string_table.
    LOOP AT lt_items INTO DATA(lv_item).
      INSERT lv_item INTO TABLE lt_items.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_003.
    DATA lt_items TYPE string_table.
    LOOP AT lt_items INTO DATA(lv_item).
      MODIFY lt_items FROM lv_item.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_004.
    DATA lt_items TYPE string_table.
    LOOP AT lt_items INTO DATA(lv_item).
      DELETE lt_items.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_006.
    DATA lt_items TYPE string_table.
    DATA lt_other TYPE string_table.
    LOOP AT lt_items INTO DATA(lv_item).
      APPEND lv_item TO lt_other.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_007.
    DATA lt_items TYPE string_table.
    LOOP AT lt_items INTO DATA(lv_item).
    ENDLOOP.
    APPEND 'A' TO lt_items.
  ENDMETHOD.

  METHOD test_008.
    DATA lt_items TYPE string_table.
    LOOP AT lt_items INTO DATA(lv_item).
      APPEND lv_item TO lt_items. "#EC LOOP_MODIFY
    ENDLOOP.
  ENDMETHOD.

  METHOD test_009.
    DATA: lt_items TYPE string_table, lt_inner TYPE string_table.
    LOOP AT lt_items INTO DATA(lv_item).
      LOOP AT lt_inner INTO DATA(lv_inner).
      ENDLOOP.
      APPEND lv_item TO lt_items.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_011.
    DATA lt_items TYPE string_table.
    DATA lt_other TYPE string_table.
    LOOP AT lt_items INTO DATA(lv_item).
      SORT lt_other.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_012.
    DATA lt_items TYPE string_table.
    LOOP AT lt_items INTO DATA(lv_item).
      COLLECT lv_item INTO lt_items.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

FORM test_005.
  DATA lt_items TYPE string_table.
  LOOP AT lt_items INTO DATA(lv_item).
      CLEAR lt_items.
  ENDLOOP.
ENDFORM.

FORM test_010.
  DATA lt_items TYPE string_table.
  LOOP AT lt_items INTO DATA(lv_item).
      SORT lt_items.
  ENDLOOP.
ENDFORM.
