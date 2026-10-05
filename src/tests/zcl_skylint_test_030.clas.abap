CLASS zcl_skylint_test_030 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_030 IMPLEMENTATION.
  METHOD with_finding.
    LOOP AT lt_tab INTO ls_row.
    SELECT SINGLE * FROM t001 INTO @ls_row WHERE field = @ls_key.
    ENDLOOP.
  ENDMETHOD.

  METHOD clean_code.
    SELECT SINGLE * FROM t001 INTO @ls_row WHERE field = @ls_key.
  ENDMETHOD.
ENDCLASS.
