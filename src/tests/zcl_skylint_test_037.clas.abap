CLASS zcl_skylint_test_037 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_037 IMPLEMENTATION.
  METHOD with_finding.
    TRY.
    ENDTRY.
  ENDMETHOD.

  METHOD clean_code.
    TRY.
    CATCH cx_root.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
