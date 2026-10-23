CLASS lcl_node DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS get_tokens RETURNING VALUE(rv_val) TYPE i.
ENDCLASS.

CLASS lcl_node IMPLEMENTATION.
  METHOD get_tokens.
    rv_val = 1.
  ENDMETHOD.
ENDCLASS.

CLASS zcl_test_prefer_inl_cast DEFINITION
  PUBLIC
  FINAL
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

CLASS zcl_test_prefer_inl_cast IMPLEMENTATION.
  METHOD test_001.
    DATA(lo_object) = NEW lcl_node( ).
    DATA(lv_helper) = CAST lcl_node( lo_object ).
    DATA(lv_result) = lv_helper->get_tokens( ).
  ENDMETHOD.

  METHOD test_002.
    DATA(lo_object) = NEW lcl_node( ).
    DATA(lv_helper) = CAST lcl_node( lo_object ).
    DATA(lv_result) = lv_helper.
  ENDMETHOD.

  METHOD test_003.
    DATA(lo_object) = NEW lcl_node( ).
    DATA(lv_helper) = CAST lcl_node( lo_object ).
    DATA(lv_other) = lv_helper->get_tokens( ).
    DATA(lv_result) = lv_helper->get_tokens( ).
  ENDMETHOD.

  METHOD test_004.
    DATA(lo_object) = NEW lcl_node( ).
    DATA(lv_helper) = CAST lcl_node( lo_object ).
    lv_helper = NEW lcl_node( ).
  ENDMETHOD.
  METHOD test_005.
    DATA(lo_object) = NEW lcl_node( ).
    DATA(lv_helper) = CAST lcl_node( lo_object ).
    DATA(lv_result) = lv_helper->get_tokens( ).
    DATA(lv_other) = lv_helper->get_tokens( ).
  ENDMETHOD.

  METHOD test_006.
    DATA(lo_object) = NEW lcl_node( ).
    DATA(lv_helper) = CAST lcl_node( lo_object ).
    lv_helper = NEW lcl_node( ).
    DATA(lv_result) = lv_helper->get_tokens( ).
  ENDMETHOD.

  METHOD test_007.
    DATA(lo_object) = NEW lcl_node( ).
    DATA(lv_helper) = CAST lcl_node( lo_object ).
    WRITE lv_helper->get_tokens( ).
  ENDMETHOD.
ENDCLASS.
