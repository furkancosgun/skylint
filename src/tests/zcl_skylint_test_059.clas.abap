CLASS zcl_skylint_test_059 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_059 IMPLEMENTATION.
  METHOD with_finding.
    INTERFACE lif_test PUBLIC.
    DATA mv_state TYPE i.
  ENDMETHOD.

  METHOD clean_code.
    INTERFACE lif_clean PUBLIC.
    CONSTANTS c_version TYPE i VALUE 1.
  ENDMETHOD.
ENDCLASS.
