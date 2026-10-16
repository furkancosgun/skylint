CLASS zcl_skylint_test_007 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.


CLASS zcl_skylint_test_007 IMPLEMENTATION.
  METHOD test_001.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_c TYPE i.
    lv_a = lv_b = lv_c.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    lv_a = lv_b.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_x TYPE i.
    DATA lv_y TYPE i.
    lv_x = lv_y = 10.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_x TYPE i.
    DATA lv_y TYPE i.
    lv_x = lv_y + 1.
  ENDMETHOD.
ENDCLASS.

