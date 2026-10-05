CLASS zcl_skylint_test_061 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_061 IMPLEMENTATION.
  METHOD with_finding.
    MESSAGE ID 'Z1' TYPE 'E' RAISING cx_static_check.
  ENDMETHOD.

  METHOD clean_code.
    MESSAGE ID 'Z1' TYPE 'E'.
  ENDMETHOD.
ENDCLASS.
