CLASS zcl_skylint_test_007 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_007 IMPLEMENTATION.
  METHOD with_finding.
    lv_a = lv_b = lv_c.
  ENDMETHOD.

  METHOD clean_code.
    lv_a = lv_b.
  ENDMETHOD.
ENDCLASS.
