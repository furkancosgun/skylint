CLASS zcl_skylint_test_001 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_001 IMPLEMENTATION.
  METHOD with_finding.
    DESCRIBE TABLE lt_tab LINES lv_cnt.
  ENDMETHOD.

  METHOD clean_code.
    lv_cnt = lines( lt_tab ).
  ENDMETHOD.
ENDCLASS.
