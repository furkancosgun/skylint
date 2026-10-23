CLASS zcl_test_no_concat_loop DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
    METHODS test_006.
    METHODS test_007.
ENDCLASS.

CLASS zcl_test_no_concat_loop IMPLEMENTATION.
  METHOD test_001.
    DATA lt_items TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA lv_text  TYPE string.
    DATA lv_item  TYPE string.
    LOOP AT lt_items INTO lv_item.
      lv_text = lv_text && lv_item.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_text TYPE string.
    DATA lv_item TYPE string.
    lv_text = lv_text && lv_item.
  ENDMETHOD.

  METHOD test_003.
    DATA lt_items TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA lv_text  TYPE string.
    DATA lv_item  TYPE string.
    LOOP AT lt_items INTO lv_item.
      CONCATENATE lv_text lv_item INTO lv_text.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_004.
    DATA lt_items TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA lv_text  TYPE string.
    DATA lv_item  TYPE string.
    LOOP AT lt_items INTO lv_item.
      CONCATENATE lv_item 'x' INTO lv_text.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_005.
    DATA lt_items TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA lv_text  TYPE string.
    DATA lv_item  TYPE string.
    LOOP AT lt_items INTO lv_item.
      lv_text = |{ lv_text }x|.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_006.
    DATA lt_items TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA lv_text  TYPE string.
    DATA lv_item  TYPE string.
    LOOP AT lt_items INTO lv_item.
      lv_text = |{ lv_item }x|.
    ENDLOOP.
  ENDMETHOD.

  METHOD test_007.
    DATA lt_items TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    DATA lv_text  TYPE string.
    DATA lv_item  TYPE string.
    LOOP AT lt_items INTO lv_item.
      lv_text = lv_item && 'x'.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
