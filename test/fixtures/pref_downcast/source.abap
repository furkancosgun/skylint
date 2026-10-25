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

CLASS zcl_test_prefer_cast DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.

CLASS zcl_test_prefer_cast IMPLEMENTATION.
  METHOD test_001.
    DATA lo_child TYPE REF TO zcl_test_prefer_cast.
    DATA lo_parent TYPE REF TO object.
    lo_child ?= lo_parent.
  ENDMETHOD.

  METHOD test_002.
    DATA lo_child TYPE REF TO zcl_test_prefer_cast.
    DATA lo_parent TYPE REF TO object.
    lo_child = CAST #( lo_parent ).
  ENDMETHOD.

  METHOD test_003.
    DATA lo_child TYPE REF TO zcl_test_prefer_cast.
    DATA lo_parent TYPE REF TO object.
    MOVE lo_parent ?TO lo_child.
  ENDMETHOD.

  METHOD test_004.
    DATA lo_child TYPE REF TO zcl_test_prefer_cast.
    DATA lo_parent TYPE REF TO object.
    lo_parent = lo_child.
  ENDMETHOD.
ENDCLASS.

CLASS zcl_test_prefer_inl_cast DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_005.
    METHODS test_006.
    METHODS test_007.
    METHODS test_008.
ENDCLASS.

CLASS zcl_test_prefer_inl_cast IMPLEMENTATION.
  METHOD test_005.
    DATA(lo_object) = NEW lcl_node( ).
    DATA(lv_helper) = CAST lcl_node( lo_object ).
    DATA(lv_result) = lv_helper->get_tokens( ).
  ENDMETHOD.

  METHOD test_006.
    DATA(lo_object) = NEW lcl_node( ).
    DATA(lv_helper) = CAST lcl_node( lo_object ).
    DATA(lv_result) = lv_helper.
  ENDMETHOD.

  METHOD test_007.
    DATA(lo_object) = NEW lcl_node( ).
    DATA(lv_helper) = CAST lcl_node( lo_object ).
    DATA(lv_other) = lv_helper->get_tokens( ).
    DATA(lv_result) = lv_helper->get_tokens( ).
  ENDMETHOD.

  METHOD test_008.
    DATA(lo_object) = NEW lcl_node( ).
    DATA(lv_helper) = CAST lcl_node( lo_object ).
    lv_helper = NEW lcl_node( ).
  ENDMETHOD.
ENDCLASS.
