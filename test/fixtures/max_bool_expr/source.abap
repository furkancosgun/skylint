CLASS zcl_test_max_bool_expr DEFINITION
  PUBLIC
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
ENDCLASS.

CLASS zcl_test_max_bool_expr IMPLEMENTATION.
  METHOD test_001.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_c TYPE i.
    DATA lv_d TYPE i.
    IF lv_a = 1 AND lv_b = 2 AND lv_c = 3 AND lv_d = 4.
      lv_a = 1.
    ENDIF.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_c TYPE i.
    DATA lv_d TYPE i.
    IF lv_a = 1 AND lv_b = 2 AND lv_c = 3 AND lv_d = 4 AND lv_a = 5.
      lv_a = 1.
    ENDIF.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_c TYPE i.
    DATA lv_d TYPE i.
    IF lv_a BETWEEN 1 AND 10 AND lv_b = 2 AND lv_c = 3 AND lv_d = 4.
      lv_a = 1.
    ENDIF.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_c TYPE i.
    DATA lv_d TYPE i.
    IF lv_a = 1 AND lv_b = 2 AND lv_c = 3.
      lv_a = 1.
    ENDIF.
  ENDMETHOD.

  METHOD test_005.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_c TYPE i.
    DATA lv_d TYPE i.
    IF lv_a = 0.
      lv_a = 1.
    ELSEIF lv_a = 1 AND lv_b = 2 AND lv_c = 3 AND lv_d = 4 AND lv_a = 5.
      lv_a = 2.
    ENDIF.
  ENDMETHOD.

  METHOD test_006.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_c TYPE i.
    DATA lv_d TYPE i.
    WHILE lv_a = 1 AND lv_b = 2 AND lv_c = 3 AND lv_d = 4 AND lv_a = 5.
      lv_a = lv_a + 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD test_007.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_c TYPE i.
    DATA lv_d TYPE i.
    CHECK lv_a = 1 AND lv_b = 2 AND lv_c = 3 AND lv_d = 4 AND lv_a = 5.
    lv_a = 1.
  ENDMETHOD.

  METHOD test_008.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_c TYPE i.
    DATA lv_d TYPE i.
    IF lv_a = 1 OR lv_b = 2 OR lv_c = 3 OR lv_d = 4 OR lv_a = 5.
      lv_a = 1.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
