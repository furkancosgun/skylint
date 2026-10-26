CLASS zcl_test_prefer_calc_assign_op DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_data,
             count TYPE i,
           END OF ty_data.

    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
    METHODS test_006.
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

  METHOD test_005.
    DATA lv_x TYPE i.
    lv_x = lv_x + ( 2 * 3 ).
  ENDMETHOD.

  METHOD test_006.
    DATA ls_data TYPE ty_data.
    ls_data-count = ls_data-count + 1.
  ENDMETHOD.
ENDCLASS.
