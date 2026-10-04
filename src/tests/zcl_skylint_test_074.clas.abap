CLASS zcl_skylint_test_074 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_074 IMPLEMENTATION.
  METHOD with_finding.
    LOOP AT lt_tab INTO ls_row.
    IF ls_row-flag = abap_true.
    ls_val = 1.
    ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD clean_code.
    LOOP AT lt_tab INTO ls_row.
    ls_val = 1.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
