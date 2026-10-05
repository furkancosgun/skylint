CLASS zcl_skylint_test_025 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_025 IMPLEMENTATION.
  METHOD with_finding.
    CALL METHOD lo_obj->run RECEIVING rv_val = lv_x.
  ENDMETHOD.

  METHOD clean_code.
    CALL METHOD lo_obj->run EXPORTING iv_in = lv_x.
  ENDMETHOD.
ENDCLASS.
