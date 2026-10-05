CLASS zcl_skylint_test_023 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_023 IMPLEMENTATION.
  METHOD with_finding.
    RAISE EXCEPTION TYPE cx_static_check.
  ENDMETHOD.

  METHOD clean_code.
    RAISE EXCEPTION NEW cx_static_check( ).
  ENDMETHOD.
ENDCLASS.
