CLASS zcl_skylint_test_073 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_073 IMPLEMENTATION.
  METHOD with_finding.
    lv_x = lv_x + 1.
  ENDMETHOD.

  METHOD clean_code.
    lv_x = 10.
  ENDMETHOD.
ENDCLASS.
