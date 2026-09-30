CLASS zcl_skylint_test_063 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_063 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lv_flag TYPE abap_bool VALUE abap_true.
    DATA lv_text TYPE string.
    IF lv_flag = abap_true.
      lv_text = 'YES'.
    ELSE.
      lv_text = 'NO'.
    ENDIF.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lv_flag TYPE abap_bool VALUE abap_true.
    DATA lv_text TYPE string.
    IF lv_flag = abap_true. "#EC PREFER_COND
      lv_text = 'YES'.
    ELSE.
      lv_text = 'NO'.
    ENDIF.
  ENDMETHOD.

  METHOD valid_code.
    DATA lv_flag TYPE abap_bool VALUE abap_true.
    DATA lv_text TYPE string.
    lv_text = COND #( WHEN lv_flag = abap_true THEN 'YES' ELSE 'NO' ).
  ENDMETHOD.
ENDCLASS.
