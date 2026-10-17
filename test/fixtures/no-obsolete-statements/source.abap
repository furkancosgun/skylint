CLASS zcl_test_no_obsolete_statement DEFINITION
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
ENDCLASS.


CLASS zcl_test_no_obsolete_statement IMPLEMENTATION.
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

  METHOD test_005.
    BREAK-POINT.
  ENDMETHOD.

  METHOD test_006.
    STATICS sv_stat TYPE i.
  ENDMETHOD.

  METHOD test_007.
    DATA lv_val TYPE i.
    EXPORT lv_val TO MEMORY ID 'KEY'.
  ENDMETHOD.
ENDCLASS.
