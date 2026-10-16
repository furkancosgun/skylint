CLASS zcl_test_no_forbidden_statemen DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.

CLASS zcl_test_no_forbidden_statemen IMPLEMENTATION.
  METHOD test_001.
    BREAK-POINT.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_val TYPE i.
    lv_val = 1.
  ENDMETHOD.

  METHOD test_003.
    STATICS sv_stat TYPE i.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_val TYPE i.
    EXPORT lv_val TO MEMORY ID 'KEY'.
  ENDMETHOD.
ENDCLASS.
