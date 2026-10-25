CLASS zcl_test_no_obs_memory DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.

CLASS zcl_test_no_obs_memory IMPLEMENTATION.
  METHOD test_001.
    DATA lv_val TYPE i.
    EXPORT val = lv_val TO MEMORY ID 'KEY'.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_val TYPE i.
    lv_val = 1.
  ENDMETHOD.

  METHOD test_003.
    FREE MEMORY ID 'KEY'.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_ok TYPE abap_bool.
    IF lv_ok = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
