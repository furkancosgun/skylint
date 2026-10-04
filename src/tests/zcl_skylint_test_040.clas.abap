CLASS zcl_skylint_test_040 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_040 IMPLEMENTATION.
  METHOD with_finding.
    IF lv_a = 1.
    IF lv_b = 2.
    IF lv_c = 3.
    IF lv_d = 4.
    ENDIF.
    ENDIF.
    ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD clean_code.
    IF lv_a = 1.
    IF lv_b = 2.
    ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
