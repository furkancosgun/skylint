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
    DATA lv_c TYPE i.
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

CLASS lcl_bad_ctor DEFINITION.
  PUBLIC SECTION.
    METHODS constructor.
ENDCLASS.

CLASS lcl_bad_ctor IMPLEMENTATION.
  METHOD constructor.
    DATA lv_val TYPE i.
    lv_val = 1.
    lv_val = 2.
    lv_val = 3.
    lv_val = 4.
    lv_val = 5.
    lv_val = 6.
    lv_val = 7.
    lv_val = 8.
    lv_val = 9.
    lv_val = 10.
    lv_val = 11.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_good_ctor DEFINITION.
  PUBLIC SECTION.
    METHODS constructor.
ENDCLASS.

CLASS lcl_good_ctor IMPLEMENTATION.
  METHOD constructor.
    DATA lv_x TYPE i.
    lv_x = 1.
  ENDMETHOD.
ENDCLASS.
