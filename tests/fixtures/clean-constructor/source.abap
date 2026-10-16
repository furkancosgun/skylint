CLASS zcl_test_clean_constructor DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.

CLASS zcl_test_clean_constructor IMPLEMENTATION.
  METHOD constructor.
    DATA lv_val TYPE i.
    lv_val = 1.
    lv_val = 1.
    lv_val = 1.
    lv_val = 1.
    lv_val = 1.
    lv_val = 1.
    lv_val = 1.
    lv_val = 1.
    lv_val = 1.
    lv_val = 1.
    lv_val = 1.
  ENDMETHOD.

  METHOD test_001.
    RETURN.
  ENDMETHOD.

  METHOD test_002.
    RETURN.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    lv_a = 1.
    lv_b = 2.
    lv_a = 3.
    lv_b = 4.
    lv_a = 5.
    lv_b = 6.
    lv_a = 7.
    lv_b = 8.
    lv_a = 9.
    lv_b = 10.
    lv_a = 11.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_a TYPE i.
    lv_a = 1.
  ENDMETHOD.
ENDCLASS.
