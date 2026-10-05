CLASS zcl_skylint_test_033 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.


CLASS zcl_skylint_test_033 IMPLEMENTATION.
  METHOD test_001.
    DATA lv_flag TYPE abap_bool.
    IF lv_flag = abap_true.
    DATA lv_inner TYPE i.
    ENDIF.
    lv_inner = 1.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_val TYPE i.
    lv_val = 1.
  ENDMETHOD.
ENDCLASS.

