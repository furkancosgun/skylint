CLASS zcl_test_prefer_def_top DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
ENDCLASS.


CLASS zcl_test_prefer_def_top IMPLEMENTATION.
  METHOD test_001.
    lv_a = 1.
    DATA lv_b TYPE i.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_b TYPE i.
    lv_a = 1.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_b TYPE i.
    CLEAR lv_b.
    FIELD-SYMBOLS <fs> TYPE i.
  ENDMETHOD.
ENDCLASS.
