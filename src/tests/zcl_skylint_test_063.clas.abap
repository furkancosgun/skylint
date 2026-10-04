CLASS zcl_skylint_test_063 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_063 IMPLEMENTATION.
  METHOD with_finding.
    RAISE EXCEPTION TYPE cx_sy_zerodivide.
  ENDMETHOD.

  METHOD clean_code.
    RAISE EXCEPTION TYPE cx_static_check.
  ENDMETHOD.
ENDCLASS.
