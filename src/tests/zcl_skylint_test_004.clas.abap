CLASS zcl_skylint_test_004 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_004 IMPLEMENTATION.
  METHOD with_finding.
    IF NOT lv_x IS INITIAL.
  ENDMETHOD.

  METHOD clean_code.
    IF lv_x IS NOT INITIAL.
  ENDMETHOD.
ENDCLASS.
