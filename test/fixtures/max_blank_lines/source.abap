CLASS zcl_test_max_blank_lines DEFINITION.
  PUBLIC SECTION.
    DATA mv_value TYPE i.

    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.

CLASS zcl_test_max_blank_lines IMPLEMENTATION.

  METHOD test_001.
    DATA lv_aux TYPE i.


    lv_aux = 1.
    mv_value = lv_aux.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_aux TYPE i.

    lv_aux = 1.

    mv_value = lv_aux.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_aux TYPE i.


    lv_aux = 1. "#EC MAX_BLANK_LINES
    mv_value = lv_aux.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_aux TYPE i.
    lv_aux = 1.
    mv_value = lv_aux.
  ENDMETHOD.

ENDCLASS.
