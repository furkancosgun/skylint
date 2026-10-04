CLASS zcl_skylint_test_028 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_028 IMPLEMENTATION.
  METHOD with_finding.
    MOVE lv_a TO lv_b.
  ENDMETHOD.

  METHOD clean_code.
    lv_b = lv_a.
  ENDMETHOD.
ENDCLASS.
