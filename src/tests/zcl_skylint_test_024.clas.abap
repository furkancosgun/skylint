CLASS zcl_skylint_test_024 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_024 IMPLEMENTATION.
  METHOD with_finding.
    IF lv_a = lv_b.
    lv_flag = abap_true.
    ELSE.
    lv_flag = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD clean_code.
    IF lv_a = lv_b.
    lv_x = abap_true.
    ELSE.
    lv_y = abap_false.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
