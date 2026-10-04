CLASS zcl_skylint_test_068 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_068 IMPLEMENTATION.
  METHOD with_finding.
    LOOP AT lt_tab INTO ls_row.
    MODIFY lt_tab FROM ls_row.
    ENDLOOP.
  ENDMETHOD.

  METHOD clean_code.
    LOOP AT lt_tab INTO ls_row.
    MODIFY lt_tab FROM ls_row TRANSPORTING field1.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
