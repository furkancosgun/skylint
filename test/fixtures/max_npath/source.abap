CLASS zcl_skylint_test_max_npath DEFINITION
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
ENDCLASS.

CLASS zcl_skylint_test_max_npath IMPLEMENTATION.
  METHOD test_001.
    DATA lv_a TYPE i.
    lv_a = 1.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_a TYPE i.
    IF lv_a = 1.
      lv_a = 2.
    ENDIF.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_a TYPE i.
    IF lv_a = 1.
      lv_a = 1.
    ENDIF.
    IF lv_a = 2.
      lv_a = 2.
    ENDIF.
    IF lv_a = 3.
      lv_a = 3.
    ENDIF.
    IF lv_a = 4.
      lv_a = 4.
    ENDIF.
    IF lv_a = 5.
      lv_a = 5.
    ENDIF.
    IF lv_a = 6.
      lv_a = 6.
    ENDIF.
    IF lv_a = 7.
      lv_a = 7.
    ENDIF.
    IF lv_a = 8.
      lv_a = 8.
    ENDIF.
  ENDMETHOD.

  METHOD test_004. "#EC MAX_NPATH
    DATA lv_a TYPE i.
    IF lv_a = 1.
      lv_a = 1.
    ENDIF.
    IF lv_a = 2.
      lv_a = 2.
    ENDIF.
    IF lv_a = 3.
      lv_a = 3.
    ENDIF.
    IF lv_a = 4.
      lv_a = 4.
    ENDIF.
    IF lv_a = 5.
      lv_a = 5.
    ENDIF.
    IF lv_a = 6.
      lv_a = 6.
    ENDIF.
    IF lv_a = 7.
      lv_a = 7.
    ENDIF.
    IF lv_a = 8.
      lv_a = 8.
    ENDIF.
  ENDMETHOD.

  METHOD test_005.
    DATA lv_a TYPE i.
    IF lv_a = 1.
      IF lv_a = 2.
        IF lv_a = 3.
          IF lv_a = 4.
            lv_a = 5.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD test_006.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    IF lv_a = 1 AND lv_b = 1.
      lv_a = 1.
    ENDIF.
    IF lv_a = 2 AND lv_b = 2.
      lv_a = 2.
    ENDIF.
    IF lv_a = 3 AND lv_b = 3.
      lv_a = 3.
    ENDIF.
    IF lv_a = 4 AND lv_b = 4.
      lv_a = 4.
    ENDIF.
    IF lv_a = 5 AND lv_b = 5.
      lv_a = 5.
    ENDIF.
  ENDMETHOD.

  METHOD test_007.
    DATA lv_a TYPE i.
    CASE lv_a.
      WHEN 1.
        lv_a = 10.
      WHEN 2.
        lv_a = 20.
      WHEN 3.
        lv_a = 30.
      WHEN OTHERS.
        lv_a = 40.
    ENDCASE.
  ENDMETHOD.

  METHOD test_008.
    DATA lv_a TYPE i.
    TRY.
        lv_a = 1.
      CATCH cx_sy_zerodivide.
        lv_a = 0.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
