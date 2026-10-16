CLASS zcl_test_prefer_calc_assign_op DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.


CLASS zcl_test_prefer_calc_assign_op IMPLEMENTATION.
  METHOD test_001.
    DATA lv_x TYPE i.
    lv_x = lv_x + 1.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_x TYPE i.
    lv_x = 10.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_num TYPE i.
    SUBTRACT 1 FROM lv_num.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_x TYPE i.
    DATA lv_y TYPE i.
    lv_x = lv_y + 1.
  ENDMETHOD.
ENDCLASS.

