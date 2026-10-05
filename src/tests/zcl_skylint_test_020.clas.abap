CLASS zcl_skylint_test_020 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_020 IMPLEMENTATION.
  METHOD with_finding.
    IF 'X' = lv_code.
  ENDMETHOD.

  METHOD clean_code.
    IF lv_code = 'X'.
  ENDMETHOD.
ENDCLASS.
