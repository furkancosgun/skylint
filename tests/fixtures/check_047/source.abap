CLASS zcl_skylint_test_047 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
ENDCLASS.


CLASS zcl_skylint_test_047 IMPLEMENTATION.
  METHOD test_001.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_c TYPE i.
    DATA lv_d TYPE i.
    DATA lv_e TYPE i.
    IF lv_a = 1.
    ENDIF.
    IF lv_b = 2.
    ENDIF.
    IF lv_c = 3.
    ENDIF.
    IF lv_d = 4.
    ENDIF.
    IF lv_e = 5.
    ENDIF.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_a TYPE i.
    IF lv_a = 1.
    ENDIF.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_c TYPE i.
    IF lv_a = 1 AND lv_b = 2 OR lv_c = 3.
    ENDIF.
    WHILE lv_a < 10.
    ENDWHILE.
    IF lv_b = 4 AND lv_c = 5.
    ENDIF.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_a TYPE i.
    lv_a = 1.
  ENDMETHOD.

  METHOD test_005.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_c TYPE i.
    DATA lv_d TYPE i.
    DATA and TYPE i.
    IF lv_a = 1.
    ENDIF.
    IF lv_b = 2.
    ENDIF.
    IF lv_c = 3.
    ENDIF.
    IF lv_d = 4.
    ENDIF.
    and = 5.
  ENDMETHOD.
ENDCLASS.

