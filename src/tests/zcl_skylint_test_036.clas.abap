CLASS zcl_skylint_test_036 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_036 IMPLEMENTATION.
  METHOD with_finding.
    lo_obj->run( iv_param = lv_val ).
  ENDMETHOD.

  METHOD clean_code.
    lo_obj->run( lv_val ).
  ENDMETHOD.
ENDCLASS.
