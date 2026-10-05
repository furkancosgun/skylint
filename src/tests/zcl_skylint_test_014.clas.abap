CLASS zcl_skylint_test_014 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_014 IMPLEMENTATION.
  METHOD with_finding.
    IF lv_x = 1.
    ENDIF.
  ENDMETHOD.

  METHOD clean_code.
    IF lv_x = 1.
    lv_x = 2.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
