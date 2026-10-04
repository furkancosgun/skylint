CLASS zcl_skylint_test_047 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_047 IMPLEMENTATION.
  METHOD with_finding.
    IF lv_a = 1.
    ENDIF.
    IF lv_b = 2.
    ENDIF.
    IF lv_c = 3.
    ENDIF.
    IF lv_d = 4.
    ENDIF.
    IF lv_e = 5.
    ENDIF.
  ENDMETHOD.

  METHOD clean_code.
    IF lv_a = 1.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
