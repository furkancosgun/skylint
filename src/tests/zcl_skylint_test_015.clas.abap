CLASS zcl_skylint_test_015 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_015 IMPLEMENTATION.
  METHOD with_finding.
    TRY.
    CATCH cx_root.
    ENDTRY.
  ENDMETHOD.

  METHOD clean_code.
    TRY.
    CATCH cx_root.
    lv_x = 1.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
