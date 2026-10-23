CLASS zcl_test_no_many_parens DEFINITION
  PUBLIC
  FINAL
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
    METHODS test_010.
    METHODS test_011.
ENDCLASS.

CLASS zcl_test_no_many_parens IMPLEMENTATION.
  METHOD test_001.
    IF ( lv_a = lv_b ).
      WRITE lv_a.
    ENDIF.
  ENDMETHOD.

  METHOD test_002.
    IF lv_a = lv_b AND ( lv_c = lv_d ).
      WRITE lv_a.
    ENDIF.
  ENDMETHOD.

  METHOD test_003.
    lv_x = ( lv_y + lv_z ).
  ENDMETHOD.

  METHOD test_004.
    IF lv_a = lv_b.
      WRITE lv_a.
    ENDIF.
  ENDMETHOD.

  METHOD test_005.
    IF NOT ( lv_a = lv_b ).
      WRITE lv_a.
    ENDIF.
  ENDMETHOD.

  METHOD test_006.
    SELECT SINGLE mandt FROM t000 WHERE mandt IN ( '100', '200' ) INTO @DATA(lv_mandt).
  ENDMETHOD.

  METHOD test_007.
    WRITE 1.
  ENDMETHOD.
  METHOD test_008.
    IF ( lv_a + lv_b ) = lv_c.
      WRITE lv_a.
    ENDIF.
  ENDMETHOD.

  METHOD test_009.
    IF lv_a = lv_b AND ( lv_c = lv_d OR lv_e = lv_f ).
      WRITE lv_a.
    ENDIF.
  ENDMETHOD.

  METHOD test_010.
    lv_x = ( lv_y + lv_z ) * 2.
  ENDMETHOD.

  METHOD test_011.
    IF ( lv_a = lv_b AND lv_c = lv_d ).
      WRITE lv_a.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
