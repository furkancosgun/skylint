CLASS zcl_skylint_test_050 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_050 IMPLEMENTATION.
  METHOD with_finding.
    lv_val = 42.
  ENDMETHOD.

  METHOD clean_code.
    lv_val = 1.
  ENDMETHOD.
ENDCLASS.
