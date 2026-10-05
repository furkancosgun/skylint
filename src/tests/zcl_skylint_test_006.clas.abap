CLASS zcl_skylint_test_006 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_006 IMPLEMENTATION.
  METHOD with_finding.
    lo_obj->run( EXPORTING iv_in = lv_x ).
  ENDMETHOD.

  METHOD clean_code.
    lo_obj->run( iv_in = lv_x ).
  ENDMETHOD.
ENDCLASS.
