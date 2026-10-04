CLASS zcl_skylint_test_009 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_009 IMPLEMENTATION.
  METHOD with_finding.
    CONCATENATE lv_a lv_b INTO lv_c.
  ENDMETHOD.

  METHOD clean_code.
    lv_c = |{ lv_a }{ lv_b }|.
  ENDMETHOD.
ENDCLASS.
