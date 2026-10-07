CLASS zcl_skylint_test_034 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.


CLASS zcl_skylint_test_034 IMPLEMENTATION.
  METHOD test_001.
    DATA lv_a TYPE i.
    lv_a = lv_a.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    lv_a = lv_b.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_b TYPE i.
    lv_b = lv_b.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_m TYPE i.
    DATA lv_n TYPE i.
    lv_m = lv_n.
  ENDMETHOD.
ENDCLASS.

