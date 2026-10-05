CLASS zcl_skylint_test_044 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_044 IMPLEMENTATION.
  METHOD with_finding.
    SYNTAX-CHECK FOR lt_prog MESSAGE lv_msg LINE lv_lin WORD lv_wrd.
  ENDMETHOD.

  METHOD clean_code.
    CHECK lv_flag = abap_true.
  ENDMETHOD.
ENDCLASS.
