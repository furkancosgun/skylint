REPORT z_test_no_unused_param.

CLASS zcl_test_no_unused_param DEFINITION.
  PUBLIC SECTION.
    METHODS test_001 IMPORTING iv_used TYPE i iv_unused TYPE string.
    METHODS test_002 IMPORTING iv_used TYPE i.
    METHODS test_003 IMPORTING _iv_ignored TYPE i.
    METHODS test_004 IMPORTING iv_unused TYPE i.
    METHODS test_005.
ENDCLASS.

CLASS zcl_test_no_unused_param IMPLEMENTATION.
  METHOD test_001.
    DATA lv_val TYPE i.
    lv_val = iv_used.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_val TYPE i.
    lv_val = iv_used.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_val TYPE i.
    lv_val = 1.
  ENDMETHOD.

  METHOD test_004. "#EC NO_UNUSED_PARAM
    DATA lv_val TYPE i.
    lv_val = 1.
  ENDMETHOD.

  METHOD test_005.
    DATA lv_val TYPE i.
    lv_val = 1.
  ENDMETHOD.
ENDCLASS.

FORM test_form_001 USING uv_used TYPE i uv_unused TYPE string.
  DATA lv_val TYPE i.
  lv_val = uv_used.
ENDFORM.

FORM test_form_002 USING uv_used TYPE i.
  DATA lv_val TYPE i.
  lv_val = uv_used.
ENDFORM.
