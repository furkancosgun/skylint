CLASS zcl_test_pref_inline DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.

CLASS zcl_test_pref_inline IMPLEMENTATION.
  METHOD test_001.
    DATA lv_count TYPE i.
    lv_count = 10.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    lv_a = 1.
  ENDMETHOD.
ENDCLASS.
