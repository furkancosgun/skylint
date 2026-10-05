CLASS zcl_skylint_test_034 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
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
ENDCLASS.

