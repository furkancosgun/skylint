CLASS zcl_test_prefer_xsdbool DEFINITION
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
    METHODS is_valid
      IMPORTING iv_param TYPE i OPTIONAL
      RETURNING VALUE(rv_valid) TYPE abap_bool.
ENDCLASS.


CLASS zcl_test_prefer_xsdbool IMPLEMENTATION.
  METHOD is_valid.
    rv_valid = abap_true.
  ENDMETHOD.

  METHOD test_001.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_flag TYPE abap_bool.
    IF lv_a = lv_b.
    lv_flag = abap_true.
    ELSE.
    lv_flag = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_x TYPE i.
    DATA lv_y TYPE i.
    IF lv_a = lv_b.
    lv_x = abap_true.
    ELSE.
    lv_y = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_c TYPE i.
    DATA lv_d TYPE i.
    DATA lv_flag2 TYPE abap_bool.
    IF lv_c = lv_d.
    lv_flag2 = abap_false.
    ELSE.
    lv_flag2 = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_x TYPE i.
    IF lv_a = lv_b.
    lv_x = 1.
    ELSE.
    lv_x = 2.
    ENDIF.
  ENDMETHOD.

  METHOD test_005.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_flag TYPE abap_bool.
    DATA lv_val TYPE string.
    IF lv_a = lv_b.
    lv_flag = lv_val.
    ELSE.
    lv_flag = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD test_006.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_flag TYPE abap_bool.
    IF ( lv_a = lv_b ).
      lv_flag = abap_true.
    ELSE.
      lv_flag = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD test_007.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_flag TYPE abap_bool.
    IF ( lv_a = lv_b ).
      lv_flag = abap_false.
    ELSE.
      lv_flag = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD test_008.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_flag TYPE abap_bool.
    IF ( ( lv_a = 1 ) AND ( lv_b = 2 ) ).
      lv_flag = abap_true.
    ELSE.
      lv_flag = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD test_009.
    DATA lv_a TYPE i.
    DATA lv_b TYPE i.
    DATA lv_c TYPE i.
    DATA lv_flag TYPE abap_bool.
    IF ( ( lv_a = 1 ) AND ( lv_b = 2 ) ) OR ( lv_c = 3 ).
      lv_flag = abap_true.
    ELSE.
      lv_flag = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD test_010.
    DATA lv_flag TYPE abap_bool.
    IF is_valid( iv_param = 1 ) = abap_true.
      lv_flag = abap_true.
    ELSE.
      lv_flag = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD test_011.
    DATA lv_flag TYPE abap_bool.
    IF ( is_valid( ) = abap_true ).
      lv_flag = abap_true.
    ELSE.
      lv_flag = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD test_012.
    DATA lv_flag TYPE abap_bool.
    IF is_valid( iv_param = 1 ).
      lv_flag = abap_true.
    ELSE.
      lv_flag = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD test_013.
    DATA lv_a TYPE i.
    DATA lv_flag TYPE abap_bool.
    IF ( is_valid( ) AND ( lv_a = 1 ) ).
      lv_flag = abap_true.
    ELSE.
      lv_flag = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD test_014.
    DATA lv_a TYPE i.
    DATA lv_flag TYPE abap_bool.
    DATA lv_count TYPE i.
    IF ( lv_a = 1 ).
      lv_flag = abap_true.
      lv_count = 1.
    ELSE.
      lv_flag = abap_false.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
