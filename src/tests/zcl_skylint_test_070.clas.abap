CLASS zcl_skylint_test_070 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_070 IMPLEMENTATION.
  METHOD with_finding.
    SELECT * FROM (lv_tab) INTO TABLE lt_tab.
  ENDMETHOD.

  METHOD clean_code.
    SELECT * FROM t001 INTO TABLE lt_tab.
  ENDMETHOD.
ENDCLASS.
