CLASS zcl_skylint_test_no_dead_code DEFINITION PUBLIC CREATE PUBLIC.
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
    METHODS test_010.
ENDCLASS.

CLASS zcl_skylint_test_no_dead_code IMPLEMENTATION.
  METHOD test_001.
    IF 1 = 2.
      DATA lv_a TYPE i.
    ENDIF.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_b TYPE i.
    IF lv_b = 2.
      lv_b = 3.
    ENDIF.
  ENDMETHOD.

  METHOD test_003.
    IF -5 > +3.
      DATA lv_c TYPE i.
    ENDIF.
  ENDMETHOD.

  METHOD test_004.
    IF -3 > -5.
      DATA lv_d TYPE i.
    ENDIF.
  ENDMETHOD.

  METHOD test_005.
    IF 5 BETWEEN 1 AND 3.
      DATA lv_e TYPE i.
    ENDIF.
  ENDMETHOD.

  METHOD test_006.
    IF 2 BETWEEN 1 AND 3.
      DATA lv_f TYPE i.
    ENDIF.
  ENDMETHOD.

  METHOD test_007.
    IF 'Z' BETWEEN 'A' AND 'C'.
      DATA lv_g TYPE i.
    ENDIF.
  ENDMETHOD.

  METHOD test_008.
    IF 'B' BETWEEN 'A' AND 'C'.
      DATA lv_h TYPE i.
    ENDIF.
  ENDMETHOD.

  METHOD test_009.
    IF 'A' = 'B'.
      DATA lv_i TYPE i.
    ENDIF.
  ENDMETHOD.

  METHOD test_010.
    DATA lv_j TYPE i.
    IF lv_j BETWEEN 1 AND 3.
      lv_j = 1.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
