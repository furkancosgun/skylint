CLASS zcl_skylint_test_011 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_011 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    DATA lv_flag TYPE abap_bool VALUE abap_true.
    IF lv_flag = abap_true.
      RETURN.
    ENDIF.
  ENDMETHOD.

  METHOD with_pseudo_comments.
    DATA lv_flag TYPE abap_bool VALUE abap_true.
    IF lv_flag = abap_true. "#EC AVOID_BOOL_COMP
      RETURN.
    ENDIF.
  ENDMETHOD.

  METHOD valid_code.
    DATA lv_flag TYPE abap_bool VALUE abap_true.
    DATA lv_name TYPE string VALUE 'SKYLINT'.
    IF lv_flag.
      RETURN.
    ENDIF.
    IF NOT lv_flag.
      RETURN.
    ENDIF.
    IF lv_name = 'SKYLINT'.
      RETURN.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
