CLASS zcl_skylint_test_keyword_name DEFINITION PUBLIC CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
ENDCLASS.

CLASS zcl_skylint_test_keyword_name IMPLEMENTATION.
  METHOD test_001.
    DATA class TYPE string.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_name TYPE string.
    DATA(table) = 1.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_valid TYPE string.
    DATA(lv_num) = 42.
  ENDMETHOD.
ENDCLASS.
