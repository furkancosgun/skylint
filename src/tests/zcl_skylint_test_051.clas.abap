CLASS zcl_skylint_test_051 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_051 IMPLEMENTATION.
  METHOD with_finding.
    APPEND ls_row TO lt_tab.
  ENDMETHOD.

  METHOD clean_code.
    INSERT ls_row INTO TABLE lt_tab.
  ENDMETHOD.
ENDCLASS.
