CLASS zcl_test_no_yoda_conditions DEFINITION
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
    METHODS test_009.
ENDCLASS.

CLASS zcl_test_no_yoda_conditions IMPLEMENTATION.
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

  METHOD test_005.
    DATA table TYPE i.
    IF 0 = table.
    ENDIF.
  ENDMETHOD.

  METHOD test_006.
    IF 'A' = 'B'.
    ENDIF.
  ENDMETHOD.

  METHOD test_007.
    DATA lt_tab TYPE string_table.
    IF 0 = lines( lt_tab ).
    ENDIF.
  ENDMETHOD.

  METHOD test_008.
    DATA lv_str TYPE string.
    IF '-1' = lv_str.
    ENDIF.
  ENDMETHOD.

  METHOD test_009.
    DATA lv_str TYPE string.
    IF 'foo' CS lv_str.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
