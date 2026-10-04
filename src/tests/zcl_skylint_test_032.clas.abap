CLASS zcl_skylint_test_032 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_032 IMPLEMENTATION.
  METHOD with_finding.
    SELECT * FROM t001 INTO @DATA(ls_row).
    ENDSELECT.
  ENDMETHOD.

  METHOD clean_code.
    SELECT field1 FROM t001 INTO TABLE lt_tab.
  ENDMETHOD.
ENDCLASS.
