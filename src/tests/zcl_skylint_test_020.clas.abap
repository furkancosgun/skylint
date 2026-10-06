CLASS zcl_skylint_test_020 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.

CLASS zcl_skylint_test_020 IMPLEMENTATION.
  METHOD test_001.
    DATA lv_code TYPE c LENGTH 1.
    IF 'X' = lv_code.
    ENDIF.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_code TYPE c LENGTH 1.
    IF lv_code = 'X'.
    ENDIF.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_num TYPE i.
    IF 0 = lv_num.
    ENDIF.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_num TYPE i.
    IF lv_num <> 0.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
