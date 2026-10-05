CLASS zcl_skylint_test_069 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_069 IMPLEMENTATION.
  METHOD with_finding.
    METHODS bad_name FOR TESTING.
  ENDMETHOD.

  METHOD clean_code.
    METHODS test_something FOR TESTING.
  ENDMETHOD.
ENDCLASS.
