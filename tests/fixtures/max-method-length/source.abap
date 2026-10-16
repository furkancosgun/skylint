CLASS zcl_test_max_method_length DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.


CLASS zcl_test_max_method_length IMPLEMENTATION.
  METHOD test_001.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_c TYPE i.
    DATA lv_d TYPE i.
    DATA lv_e TYPE i.
    DATA lv_f TYPE i.
    lv_a = 1.
    lv_b = 2.
    lv_c = 3.
    lv_d = 4.
    lv_e = 5.
    lv_f = 6.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    lv_a = 1.
    lv_b = 2.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_m TYPE i.
    DATA lv_n TYPE i.
    DATA lv_o TYPE i.
    lv_m = 1.
    lv_n = 2.
    lv_o = 3.
    lv_m = lv_n.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_p TYPE i.
    DATA lv_q TYPE i.
    DATA lv_r TYPE i.
    lv_p = 1.
    lv_q = 2.
  ENDMETHOD.
ENDCLASS.

