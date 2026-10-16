CLASS zcl_test_no_inline_length DEFINITION
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
ENDCLASS.


CLASS zcl_test_no_inline_length IMPLEMENTATION.
  METHOD test_001.
    DATA lv_text(30) TYPE c.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_text TYPE c LENGTH 30.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_flag(1) TYPE c.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_count TYPE i.
    lv_count = 1.
  ENDMETHOD.

  METHOD test_005.
    CONSTANTS lc_len TYPE i VALUE 30.
    DATA lv_text(lc_len).
  ENDMETHOD.

  METHOD test_006.
    DATA lv_text(lv_len).
  ENDMETHOD.

  METHOD test_007.
    DATA lv_raw(10).
  ENDMETHOD.

  METHOD test_008.
    DATA lv_text TYPE c LENGTH 10.
    DATA lv_like(5) LIKE lv_text.
  ENDMETHOD.
ENDCLASS.
