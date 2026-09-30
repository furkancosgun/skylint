INTERFACE lif_test_bad.
  DATA gv_flag TYPE abap_bool.
  DATA gv_pc TYPE abap_bool. "#EC INTERFACE_DATA
  CONSTANTS c_ok TYPE abap_bool VALUE abap_true.
ENDINTERFACE.

CLASS zcl_skylint_test_073 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES lif_test_bad.
    METHODS without_pseudo_comments.
    METHODS with_pseudo_comments.
    METHODS valid_code.
ENDCLASS.


CLASS zcl_skylint_test_073 IMPLEMENTATION.
  METHOD without_pseudo_comments.
    " Implementation
  ENDMETHOD.

  METHOD with_pseudo_comments.
    " Implementation
  ENDMETHOD.

  METHOD valid_code.
    " Implementation
  ENDMETHOD.
ENDCLASS.
