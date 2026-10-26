CLASS zcl_skylint_test_pref_cond DEFINITION.
  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
ENDCLASS.

CLASS zcl_skylint_test_pref_cond IMPLEMENTATION.

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
    TYPES: BEGIN OF ty_data,
             grade TYPE string,
           END OF ty_data.
    DATA ls_data TYPE ty_data.
    DATA lv_score TYPE i VALUE 85.

    IF lv_score >= 90.
      ls_data-grade = 'A'.
    ELSE.
      ls_data-grade = 'B'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
