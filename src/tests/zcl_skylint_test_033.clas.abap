CLASS zcl_skylint_test_033 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_033 IMPLEMENTATION.
  METHOD with_finding.
    IF lv_flag = abap_true.
    DATA lv_inner TYPE i.
    ENDIF.
    lv_inner = 1.
  ENDMETHOD.

  METHOD clean_code.
    DATA lv_val TYPE i.
    lv_val = 1.
  ENDMETHOD.
ENDCLASS.
