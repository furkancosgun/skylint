CLASS zcl_skylint_test_026 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_026 IMPLEMENTATION.
  METHOD with_finding.
    lo_obj->do_work( ).
  ENDMETHOD.

  METHOD clean_code.
    cl_useful=>do_work( ).
  ENDMETHOD.
ENDCLASS.
