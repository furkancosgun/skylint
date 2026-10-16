CLASS zcl_skylint_test_017 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.


CLASS zcl_skylint_test_017 IMPLEMENTATION.
  METHOD test_001.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_c TYPE i.
    IF lv_a = 1.
    IF lv_b = 2.
    lv_c = 3.
    ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    IF lv_a = 1.
    lv_b = 2.
    ENDIF.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_m TYPE i.
    DATA lv_n TYPE i.
    DATA lv_r TYPE i.
    IF lv_m > 0.
    IF lv_n > 0.
    lv_r = 1.
    ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_c TYPE i.
    IF lv_a = 1.
      lv_c = 0.
      IF lv_b = 2.
        lv_c = 3.
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

