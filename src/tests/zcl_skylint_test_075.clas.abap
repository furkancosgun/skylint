CLASS zcl_skylint_test_075 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_075 IMPLEMENTATION.
  METHOD with_finding.
    IF lv_flag = abap_true.
    ls_val = 1.
    ENDIF.
  ENDMETHOD.

  METHOD clean_code.
    IF lv_flag = abap_true.
    ls_val = 1.
    ELSE.
    ls_val = 2.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
