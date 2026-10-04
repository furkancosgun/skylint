CLASS zcl_skylint_test_013 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_013 IMPLEMENTATION.
  METHOD with_finding.
    LOOP AT lt_tab INTO ls_row.
    CHECK lv_flag.
    ENDLOOP.
  ENDMETHOD.

  METHOD clean_code.
    CHECK lv_flag.
  ENDMETHOD.
ENDCLASS.
