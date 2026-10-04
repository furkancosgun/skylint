CLASS zcl_skylint_test_060 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_060 IMPLEMENTATION.
  METHOD with_finding.
    CATCH cx_root.
  ENDMETHOD.

  METHOD clean_code.
    CATCH cx_static_check.
  ENDMETHOD.
ENDCLASS.
