CLASS zcl_test_no_neg_cond DEFINITION
  PUBLIC
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
ENDCLASS.

CLASS zcl_test_no_neg_cond IMPLEMENTATION.
  METHOD test_001.
    DATA lv_flag TYPE abap_bool.
    IF NOT lv_flag.
      lv_flag = abap_true.
    ELSE.
      lv_flag = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_flag TYPE abap_bool.
    IF NOT lv_flag.
      lv_flag = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    IF lv_a <> lv_b.
      lv_a = lv_b.
    ELSE.
      lv_a = lv_b + 1.
    ENDIF.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    IF lv_a NE lv_b.
      lv_a = lv_b.
    ELSE.
      lv_a = lv_b + 1.
    ENDIF.
  ENDMETHOD.

  METHOD test_005.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    IF lv_a = lv_b.
      lv_a = lv_b.
    ELSE.
      lv_a = lv_b + 1.
    ENDIF.
  ENDMETHOD.

  METHOD test_006.
    DATA lv_a TYPE i.
    IF NOT lv_a IS INITIAL.
      lv_a = 1.
    ELSE.
      lv_a = 2.
    ENDIF.
  ENDMETHOD.

  METHOD test_007.
    DATA lv_a TYPE i.
    IF lv_a IS NOT INITIAL.
      lv_a = 1.
    ELSE.
      lv_a = 2.
    ENDIF.
  ENDMETHOD.

  METHOD test_008.
    DATA lv_flag  TYPE abap_bool.
    DATA lv_other TYPE abap_bool.
    IF NOT lv_flag.
      lv_flag = abap_true.
    ELSEIF lv_other.
      lv_flag = abap_false.
    ELSE.
      lv_flag = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD test_009.
    DATA lv_flag TYPE abap_bool.
    DATA lv_a    TYPE i.
    DATA lv_b    TYPE i.
    IF NOT lv_flag.
      IF lv_a = lv_b.
        lv_a = 1.
      ELSE.
        lv_a = 2.
      ENDIF.
    ELSE.
      lv_flag = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD test_010.
    DATA lv_flag TYPE abap_bool.
    IF NOT ( lv_flag ).
      lv_flag = abap_true.
    ELSE.
      lv_flag = abap_false.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
