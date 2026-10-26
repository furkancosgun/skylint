CLASS zcl_skylint_test_no_self_compare DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
    METHODS test_006.
    METHODS test_007.
    METHODS test_008.
    METHODS test_009.
ENDCLASS.

CLASS zcl_skylint_test_no_self_compare IMPLEMENTATION.
  METHOD test_001.
    DATA lv_a TYPE i.
    IF lv_a = lv_a.
      lv_a = 1.
    ENDIF.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    IF lv_a = lv_b.
      lv_a = 1.
    ENDIF.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_x   TYPE i.
    DATA lv_res TYPE i.
    lv_res = lv_x - lv_x.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    IF lv_a = lv_a AND lv_b = 1.
      lv_a = 1.
    ENDIF.
  ENDMETHOD.

  METHOD test_005.
    DATA lv_x   TYPE i.
    DATA lv_sum TYPE i.
    lv_sum = lv_x + lv_x.
  ENDMETHOD.

  METHOD test_006.
    DATA lv_a TYPE i.
    WHILE lv_a < lv_a.
      lv_a = 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD test_007.
    DATA lv_a TYPE i.
    lv_a = lv_a.
  ENDMETHOD.

  METHOD test_008.
    DATA lv_a TYPE i.
    MOVE lv_a TO lv_a.
  ENDMETHOD.

  METHOD test_009.
    DATA lv_x TYPE i.
    DATA lv_y TYPE i.
    lv_y = lv_x - lv_y.
  ENDMETHOD.
ENDCLASS.
