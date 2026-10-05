CLASS zcl_skylint_test_012 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_012 IMPLEMENTATION.
  METHOD with_finding.
    EXIT.
  ENDMETHOD.

  METHOD clean_code.
    LOOP AT lt_tab INTO ls_row.
    EXIT.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
