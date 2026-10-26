CLASS lcl_node DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS get_tokens RETURNING VALUE(rv_val) TYPE i.
    METHODS get_tokens_param IMPORTING iv_a TYPE i RETURNING VALUE(rv_val) TYPE i.
    METHODS get_child IMPORTING iv_id TYPE i RETURNING VALUE(ro_child) TYPE REF TO lcl_node.
    METHODS consume_node IMPORTING io_node TYPE REF TO lcl_node.
ENDCLASS.

CLASS lcl_node IMPLEMENTATION.
  METHOD get_tokens.
    rv_val = 1.
  ENDMETHOD.
  METHOD get_tokens_param.
    rv_val = iv_a.
  ENDMETHOD.
  METHOD get_child.
    ro_child = me.
  ENDMETHOD.
  METHOD consume_node.
  ENDMETHOD.
ENDCLASS.

CLASS zcl_test_prefer_cast DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS get_sub IMPORTING iv_kind TYPE i OPTIONAL RETURNING VALUE(ro_sub) TYPE REF TO zcl_test_prefer_cast.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_009.
    METHODS test_010.
    METHODS test_011.
    METHODS test_012.
    METHODS test_013.
ENDCLASS.

CLASS zcl_test_prefer_cast IMPLEMENTATION.
  METHOD get_sub.
    ro_sub = me.
  ENDMETHOD.

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

  METHOD test_009.
    DATA lo_child TYPE REF TO zcl_test_prefer_cast.
    DATA lo_parent TYPE REF TO zcl_test_prefer_cast.
    lo_child ?= lo_parent->get_sub( ).
  ENDMETHOD.

  METHOD test_010.
    DATA lo_child TYPE REF TO zcl_test_prefer_cast.
    DATA lo_parent TYPE REF TO zcl_test_prefer_cast.
    lo_child ?= lo_parent->get_sub( iv_kind = ( 1 + 2 ) ).
  ENDMETHOD.

  METHOD test_011.
    DATA lo_child TYPE REF TO zcl_test_prefer_cast.
    DATA lo_parent TYPE REF TO zcl_test_prefer_cast.
    MOVE lo_parent->get_sub( iv_kind = 1 ) ?TO lo_child.
  ENDMETHOD.

  METHOD test_012.
    DATA lo_child TYPE REF TO zcl_test_prefer_cast.
    DATA lo_parent TYPE REF TO object.
    lo_child ?= lo_parent. "#EC PREF_DOWNCAST
    MOVE lo_parent ?TO lo_child. "#EC PREF_DOWNCAST
  ENDMETHOD.

  METHOD test_013.
    DATA lo_child TYPE REF TO zcl_test_prefer_cast.
    DATA lo_parent TYPE REF TO object.
    lo_child ?= lo_parent.
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
    METHODS test_014.
    METHODS test_015.
    METHODS test_016.
    METHODS test_017.
    METHODS test_018.
    METHODS test_019.
    METHODS test_020.
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

  METHOD test_014.
    DATA(lo_object) = NEW lcl_node( ).
    DATA(lv_helper) = CAST lcl_node( lo_object ).
    lv_helper->get_tokens( ).
  ENDMETHOD.

  METHOD test_015.
    DATA(lo_object) = NEW lcl_node( ).
    DATA(lv_helper) = CAST lcl_node( lo_object->get_child( iv_id = ( 1 + 2 ) ) ).
    DATA(lv_result) = lv_helper->get_tokens_param( iv_a = ( 3 * 4 ) ).
  ENDMETHOD.

  METHOD test_016.
    DATA(lo_object) = NEW lcl_node( ).
    DATA lv_helper TYPE REF TO lcl_node.
    lv_helper = CAST #( lo_object ).
    DATA(lv_result) = lv_helper->get_tokens( ).
  ENDMETHOD.

  METHOD test_017.
    DATA(lo_object) = NEW lcl_node( ).
    DATA(lv_helper) = CAST lcl_node( lo_object ).
    DATA lv_dummy TYPE i.
    DATA(lv_result) = lv_helper->get_tokens( ).
  ENDMETHOD.

  METHOD test_018.
    DATA(lo_object) = NEW lcl_node( ).
    DATA(lv_helper) = CAST lcl_node( lo_object ).
    lo_object->consume_node( lv_helper ).
  ENDMETHOD.

  METHOD test_019.
    DATA(lo_object) = NEW lcl_node( ).
    DATA(lv_helper) = CAST lcl_node( lo_object ). "#EC PREF_INLINE_CAST
    DATA(lv_result) = lv_helper->get_tokens( ).
  ENDMETHOD.

  METHOD test_020.
    DATA(lo_object) = NEW lcl_node( ).
    DATA(lv_helper) = CAST lcl_node( lo_object ).
    DATA(lv_result) = lv_helper->get_tokens( ).
  ENDMETHOD.
ENDCLASS.
