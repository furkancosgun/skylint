CLASS zcl_skylint_test_064 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_064 IMPLEMENTATION.
  METHOD with_finding.
    READ TABLE lt_tab INDEX 1.
  ENDMETHOD.

  METHOD clean_code.
    READ TABLE lt_tab INDEX 1.
    IF sy-subrc = 0.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
