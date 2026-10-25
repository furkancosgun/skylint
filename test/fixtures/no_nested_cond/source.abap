CLASS zcl_test_no_nested_cond DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.

CLASS zcl_test_no_nested_cond IMPLEMENTATION.
  METHOD test_001.
    DATA a TYPE i.
    DATA b TYPE i.
    DATA lv_val TYPE string.
    lv_val = COND #( WHEN a = 1 THEN COND #( WHEN b = 2 THEN 'X' ELSE 'Y' ) ELSE 'Z' ).
  ENDMETHOD.

  METHOD test_002.
    DATA a TYPE i.
    DATA b TYPE i.
    DATA lv_val TYPE string.
    lv_val = SWITCH #( a WHEN 1 THEN SWITCH #( b WHEN 2 THEN 'X' ELSE 'Y' ) ELSE 'Z' ).
  ENDMETHOD.

  METHOD test_003.
    DATA a TYPE i.
    DATA lv_val TYPE string.
    lv_val = COND #( WHEN a = 1 THEN 'X' ELSE 'Y' ).
  ENDMETHOD.

  METHOD test_004.
    DATA a TYPE i.
    DATA b TYPE i.
    DATA lv_val TYPE string.
    lv_val = COND #( WHEN a = 1 THEN COND #( WHEN b = 2 THEN 'X' ELSE 'Y' ) ELSE 'Z' ) ##NO_NESTED_COND. "#EC NO_NESTED_COND
  ENDMETHOD.
ENDCLASS.
