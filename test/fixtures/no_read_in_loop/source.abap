CLASS zcl_skylint_test_no_read_in_loop DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
    METHODS test_006.
    METHODS test_007.
    METHODS test_008.
    METHODS test_009.
    METHODS test_010.
    METHODS test_011.
    METHODS test_012.
ENDCLASS.

CLASS zcl_skylint_test_no_read_in_loop IMPLEMENTATION.
  METHOD test_001.
    DATA lt_orders TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA lt_items  TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA lv_order  TYPE string.
    DATA lv_item   TYPE string.
    LOOP AT lt_orders INTO lv_order.
      READ TABLE lt_items INTO lv_item WITH KEY table_line = lv_order.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_002.
    DATA lt_orders TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA lt_items  TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA lv_order  TYPE string.
    DATA lv_item   TYPE string.
    LOOP AT lt_orders INTO lv_order.
      READ TABLE lt_items INTO lv_item WHERE table_line = lv_order.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_003.
    DATA lt_items TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA lv_key   TYPE string.
    DATA lv_item  TYPE string.
    READ TABLE lt_items INTO lv_item WITH KEY table_line = lv_key.
  ENDMETHOD.

  METHOD test_004.
    TYPES: BEGIN OF ty_item,
             id   TYPE i,
             name TYPE string,
           END OF ty_item.
    DATA lt_sorted TYPE SORTED TABLE OF ty_item WITH UNIQUE KEY id.
    DATA lt_ids    TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    DATA lv_id     TYPE i.
    DATA ls_item   TYPE ty_item.
    LOOP AT lt_ids INTO lv_id.
      READ TABLE lt_sorted INTO ls_item WITH KEY id = lv_id BINARY SEARCH.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_005.
    TYPES: BEGIN OF ty_item,
             id   TYPE i,
             name TYPE string,
           END OF ty_item.
    DATA lt_sorted TYPE SORTED TABLE OF ty_item WITH UNIQUE KEY id.
    DATA lt_ids    TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    DATA lv_id     TYPE i.
    DATA ls_item   TYPE ty_item.
    LOOP AT lt_ids INTO lv_id.
      READ TABLE lt_sorted INTO ls_item WITH TABLE KEY id = lv_id.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_006.
    DATA lt_orders TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA lt_items  TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA lv_order  TYPE string.
    DATA lv_item   TYPE string.
    DATA lv_index  TYPE i.
    LOOP AT lt_orders INTO lv_order.
      lv_index = sy-tabix.
      READ TABLE lt_items INTO lv_item INDEX lv_index.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_007.
    DATA lt_keys  TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA lt_items TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA lv_key   TYPE string.
    DO 5 TIMES.
      READ TABLE lt_items TRANSPORTING NO FIELDS WITH KEY table_line = lv_key.
      lv_key = 'X'.
    ENDDO.
  ENDMETHOD.

  METHOD test_008.
    DATA lt_orders TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA lt_items  TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA lv_order  TYPE string.
    DATA lv_item   TYPE string.
    LOOP AT lt_orders INTO lv_order.
      READ TABLE lt_items INTO lv_item WITH KEY table_line = lv_order. "#EC NO_READ_LOOP
    ENDLOOP.
  ENDMETHOD.

  METHOD test_009.
    DATA lt_orders TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA lt_pos    TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA lv_order  TYPE string.
    DATA lv_pos    TYPE string.
    LOOP AT lt_orders INTO lv_order.
      LOOP AT lt_pos INTO lv_pos.
        READ TABLE lt_pos TRANSPORTING NO FIELDS WHERE table_line = lv_order.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_010.
    DATA lt_orders TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA lt_items  TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA lv_order  TYPE string.
    FIELD-SYMBOLS <ls_item> TYPE string.
    lv_order = 'A'.
    WHILE lv_order IS NOT INITIAL.
      READ TABLE lt_items ASSIGNING <ls_item> WITH KEY table_line = lv_order.
      lv_order = ''.
    ENDWHILE.
  ENDMETHOD.

  METHOD test_011.
    DATA lt_orders TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA lt_items  TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA lv_order  TYPE string.
    DATA lv_item   TYPE string.
    LOOP AT lt_orders WHERE table_line = lv_order INTO lv_order.
      lv_item = lv_order.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_012.
    DATA lt_keys   TYPE string_table.
    DATA lt_result TYPE string_table.
    DATA lt_failed TYPE string_table.
    LOOP AT lt_keys INTO DATA(lv_key).
      READ ENTITIES OF z_root ENTITY item ALL FIELDS WITH lt_keys RESULT lt_result FAILED lt_failed.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
