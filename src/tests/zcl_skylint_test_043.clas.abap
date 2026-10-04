CLASS zcl_skylint_test_043 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_043 IMPLEMENTATION.
  METHOD with_finding.
    METHODS get_data EXCEPTIONS not_found.
  ENDMETHOD.

  METHOD clean_code.
    METHODS get_data RAISING cx_static_check.
  ENDMETHOD.
ENDCLASS.
