CLASS zcl_skylint_test_num_var DEFINITION.
  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
    METHODS test_006.
    METHODS test_007.
ENDCLASS.

CLASS zcl_skylint_test_num_var IMPLEMENTATION.
  METHOD test_001.
    DATA lv_count1 TYPE i VALUE 0.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_count TYPE i VALUE 0.
  ENDMETHOD.

  METHOD test_003.
    FIELD-SYMBOLS <fs_item2> TYPE any.
  ENDMETHOD.

  METHOD test_004.
    DATA(lv_res1) = 42.
  ENDMETHOD.

  METHOD test_005.
    DATA lv_total_amount TYPE i VALUE 0.
  ENDMETHOD.

  METHOD test_006.
    DATA lv_utf8 TYPE string VALUE 'test'. "#EC NO_NUMBERED_VAR
  ENDMETHOD.

  METHOD test_007.
    DATA(lv_total) = 100.
  ENDMETHOD.
ENDCLASS.
