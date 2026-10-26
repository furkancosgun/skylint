CLASS zcl_skylint_test_pref_cond DEFINITION.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_data,
             grade TYPE string,
           END OF ty_data.

    METHODS is_valid
      IMPORTING iv_val TYPE i
      RETURNING VALUE(rv_valid) TYPE abap_bool.

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
ENDCLASS.

CLASS zcl_skylint_test_pref_cond IMPLEMENTATION.

  METHOD is_valid.
    rv_valid = xsdbool( iv_val > 50 ).
  ENDMETHOD.

  METHOD test_001.
    DATA lv_score TYPE i VALUE 85.
    DATA lv_grade TYPE string.

    IF lv_score >= 90.
      lv_grade = 'A'.
    ELSEIF lv_score >= 80.
      lv_grade = 'B'.
    ELSE.
      lv_grade = 'C'.
    ENDIF.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_score TYPE i VALUE 85.
    DATA lv_grade TYPE string.
    DATA lv_count TYPE i.

    " Compliant: multiple statements in branch
    IF lv_score >= 90.
      lv_grade = 'A'.
      lv_count = 1.
    ELSE.
      lv_grade = 'B'.
    ENDIF.
  ENDMETHOD.

  METHOD test_003.
    DATA lv_score TYPE i VALUE 85.
    DATA lv_grade TYPE string.

    " Suppressed via pseudo comment
    IF lv_score >= 90. "#EC PREF_COND
      lv_grade = 'A'.
    ELSE.
      lv_grade = 'B'.
    ENDIF.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_score TYPE i VALUE 85.
    DATA lv_grade TYPE string.

    " Compliant: already using COND #( )
    lv_grade = COND #(
      WHEN lv_score >= 90 THEN 'A'
      WHEN lv_score >= 80 THEN 'B'
      ELSE 'C' ).
  ENDMETHOD.

  METHOD test_005.
    DATA ls_data TYPE ty_data.
    DATA lv_score TYPE i VALUE 85.

    IF lv_score >= 90.
      ls_data-grade = 'A'.
    ELSE.
      ls_data-grade = 'B'.
    ENDIF.
  ENDMETHOD.

  METHOD test_006.
    DATA lv_x TYPE i VALUE 15.
    DATA lv_y TYPE i VALUE 10.
    DATA lv_res TYPE i.

    " Complex condition with parentheses and multiple boolean operators
    IF ( lv_x > 10 AND lv_y < 20 ).
      lv_res = 1.
    ELSEIF ( lv_x <= 0 OR lv_y >= 50 ).
      lv_res = 2.
    ELSE.
      lv_res = 3.
    ENDIF.
  ENDMETHOD.

  METHOD test_007.
    DATA lv_score TYPE i VALUE 85.
    DATA lv_res TYPE string.

    " Method call in condition with parentheses
    IF is_valid( lv_score ) = abap_true.
      lv_res = 'PASS'.
    ELSE.
      lv_res = 'FAIL'.
    ENDIF.
  ENDMETHOD.

  METHOD test_008.
    DATA lv_score TYPE i VALUE 60.
    DATA lv_base  TYPE i VALUE 10.
    DATA lv_val   TYPE i.

    " Parenthesized RHS arithmetic expressions
    IF lv_score > 50.
      lv_val = ( lv_base * 2 ).
    ELSE.
      lv_val = ( lv_base + 10 ).
    ENDIF.
  ENDMETHOD.

  METHOD test_009.
    DATA ls_data TYPE ty_data.
    DATA lv_score TYPE i VALUE 85.

    " Nested parentheses in condition and structure component target
    IF ( ( ls_data-grade = 'A' ) AND ( lv_score >= ( 10 + 20 ) ) ).
      ls_data-grade = 'EXCELLENT'.
    ELSE.
      ls_data-grade = 'AVERAGE'.
    ENDIF.
  ENDMETHOD.

  METHOD test_010.
    DATA lv_score TYPE i VALUE 95.
    DATA lv_grade TYPE string.

    " IF without ELSE (default require_else = abap_false)
    IF lv_score > 90.
      lv_grade = 'A'.
    ENDIF.
  ENDMETHOD.

  METHOD test_011.
    DATA lv_score TYPE i VALUE 85.
    DATA lv_grade TYPE string.
    DATA lv_other TYPE string.

    " Negative case: different targets assigned in branches
    IF lv_score > 90.
      lv_grade = 'A'.
    ELSEIF lv_score > 70.
      lv_other = 'B'.
    ELSE.
      lv_grade = 'C'.
    ENDIF.
  ENDMETHOD.

  METHOD test_012.
    DATA lv_score TYPE i VALUE 85.
    DATA lv_grade TYPE string.

    " Negative case: non-assignment statement in branch
    IF lv_score > 90.
      RETURN.
    ELSE.
      lv_grade = 'C'.
    ENDIF.
  ENDMETHOD.

  METHOD test_013.
    DATA lv_score TYPE i VALUE 85.
    DATA lv_grade TYPE string.

    " Negative case: multiple statements in ELSE branch
    IF lv_score > 90.
      lv_grade = 'A'.
    ELSE.
      lv_grade = 'B'.
      CLEAR lv_score.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
