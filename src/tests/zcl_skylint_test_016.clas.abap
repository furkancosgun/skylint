CLASS zcl_skylint_test_016 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_016 IMPLEMENTATION.
  METHOD with_finding.
    IF lv_a = 1.
    lv_b = 2.
    ELSEIF lv_a = 1.
    lv_c = 3.
    ENDIF.
  ENDMETHOD.

  METHOD clean_code.
    IF lv_a = 1.
    lv_b = 2.
    ELSEIF lv_a = 2.
    lv_c = 3.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
