CLASS zcl_skylint_test_017 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_017 IMPLEMENTATION.
  METHOD with_finding.
    IF lv_a = 1.
    IF lv_b = 2.
    lv_c = 3.
    ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD clean_code.
    IF lv_a = 1.
    lv_b = 2.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
