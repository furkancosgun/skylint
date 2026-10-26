CLASS zcl_test_merge_nested_ifs DEFINITION
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
    METHODS test_012.
    METHODS test_013.
    METHODS test_014.
    METHODS test_015.
    METHODS test_016.
    METHODS test_017.
    METHODS test_018.
ENDCLASS.


CLASS zcl_test_merge_nested_ifs IMPLEMENTATION.
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
  METHOD test_005.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_c TYPE i.
    IF lv_a = 1.
      lv_c = 0.
    ELSE.
      IF lv_b = 2.
        lv_c = 3.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD test_006.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    IF lv_a = 1.
      lv_a = 2.
    ELSE.
      lv_b = 1.
      IF lv_b = 2.
        lv_b = 3.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD test_007.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    IF lv_a = 1.
      lv_a = 2.
    ELSE.
      IF lv_b = 2.
        lv_b = 3.
      ELSE.
        lv_b = 4.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD test_008.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    IF lv_a = 1.
      IF lv_b = 2.
        lv_b = 3.
      ELSE.
        lv_b = 4.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD test_009.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    IF lv_a = 1.
      lv_a = 2.
    ELSE.
      IF lv_b = 2.
        lv_b = 3.
      ENDIF.
      lv_b = 4.
    ENDIF.
  ENDMETHOD.

  METHOD test_010.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    IF lv_a = 1.
      lv_a = 2.
    ELSEIF lv_a = 2.
      lv_a = 3.
    ELSE.
      IF lv_b = 2.
        lv_b = 3.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD test_011.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_c TYPE i.
    IF ( lv_a = 1 ).
      IF ( lv_b = 2 ).
        lv_c = 3.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD test_012.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_c TYPE i.
    DATA lv_d TYPE i.
    IF ( lv_a = 1 AND lv_b = 2 ).
      IF ( lv_c = 3 OR lv_d = 4 ).
        lv_a = 0.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD test_013.
    DATA lv_a TYPE string.
    DATA lv_b TYPE i.
    IF ( strlen( lv_a ) > 0 ).
      IF ( lv_b > 0 ).
        lv_b = 0.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD test_014.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_c TYPE i.
    IF ( lv_a = 1 ).
      IF ( lv_b = 2 ).
        IF ( lv_c = 3 ).
          lv_a = 0.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD test_015.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_c TYPE i.
    IF ( lv_a = 1 ).
      lv_c = 1.
    ELSE.
      IF ( lv_b = 2 AND lv_c = 3 ).
        lv_c = 2.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD test_016.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_c TYPE i.
    IF ( lv_a = 1 ).
      IF ( lv_b = 2 ).
        lv_c = 3.
      ENDIF.
      lv_c = 4.
    ENDIF.
  ENDMETHOD.

  METHOD test_017.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_c TYPE i.
    IF lv_a = 1. "#EC PREF_MERGE_IFS
      IF lv_b = 2.
        lv_c = 3.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD test_018.
    DATA lv_str TYPE string.
    DATA lv_res TYPE i.
    IF ( lv_res > 0 ).
      IF ( boolc( strlen( lv_str ) > 5 ) = abap_true ).
        lv_res = 1.
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

