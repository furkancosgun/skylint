CLASS zcl_skylint_test_038 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_038 IMPLEMENTATION.
  METHOD with_finding.
    MOVE-CORRESPONDING ls_src TO ls_dst.
  ENDMETHOD.

  METHOD clean_code.
    ls_dst = CORRESPONDING #( ls_src ).
  ENDMETHOD.
ENDCLASS.
