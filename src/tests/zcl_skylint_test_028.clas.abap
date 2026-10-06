CLASS zcl_skylint_test_028 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.


CLASS zcl_skylint_test_028 IMPLEMENTATION.
  METHOD test_001.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    MOVE lv_a TO lv_b.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    lv_b = lv_a.
  ENDMETHOD.

  METHOD test_003.
    DATA lt_tab TYPE STANDARD TABLE OF i WITH DEFAULT KEY.
    REFRESH lt_tab.
  ENDMETHOD.

  METHOD test_004.
    DATA lt_tab TYPE STANDARD TABLE OF i WITH DEFAULT KEY.
    CLEAR lt_tab.
  ENDMETHOD.
ENDCLASS.

