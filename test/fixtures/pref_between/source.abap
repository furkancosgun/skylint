CLASS zcl_skylint_test_pref_between DEFINITION
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
    METHODS test_010.
    METHODS test_011.
ENDCLASS.

CLASS zcl_skylint_test_pref_between IMPLEMENTATION.
  METHOD test_001.
    DATA lv_x TYPE i.
    IF lv_x >= 1 AND lv_x <= 10.
      lv_x = 1.
    ENDIF.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_x TYPE i.
    IF lv_x > 1 AND lv_x < 10.
      lv_x = 1.
    ENDIF.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_x TYPE i.
    IF lv_x > 1 AND lv_x < 10.
      lv_x = 1.
    ENDIF.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_x TYPE i.
    DATA lv_y TYPE i.
    IF lv_x >= 1 AND lv_y <= 10.
      lv_x = 1.
    ENDIF.
  ENDMETHOD.

  METHOD test_005.
    DATA lv_x TYPE i.
    IF lv_x >= 1 OR lv_x <= 10.
      lv_x = 1.
    ENDIF.
  ENDMETHOD.

  METHOD test_006.
    DATA lv_x TYPE i.
    IF 1 <= lv_x AND 10 >= lv_x.
      lv_x = 1.
    ENDIF.
  ENDMETHOD.

  METHOD test_007.
    DATA lv_x TYPE i.
    IF lv_x BETWEEN 1 AND 10.
      lv_x = 1.
    ENDIF.
  ENDMETHOD.

  METHOD test_008.
    DATA lv_x TYPE i.
    IF ( lv_x >= 1 ) AND ( lv_x <= 10 ).
      lv_x = 1.
    ENDIF.
  ENDMETHOD.

  METHOD test_009.
    DATA lv_x TYPE i.
    IF ( lv_x >= 1 AND lv_x <= 10 ).
      lv_x = 1.
    ENDIF.
  ENDMETHOD.

  METHOD test_010.
    DATA lv_x TYPE i.
    IF 1 <= lv_x AND lv_x <= 10.
      lv_x = 1.
    ENDIF.
  ENDMETHOD.

  METHOD test_011.
    DATA lv_x TYPE i.
    IF ( 1 <= lv_x ) AND ( lv_x <= 10 ).
      lv_x = 1.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
