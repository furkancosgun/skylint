CLASS zcl_skylint_test_076 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_076 IMPLEMENTATION.
  METHOD with_finding.
    ASSERT lv_x > 0.
  ENDMETHOD.

  METHOD clean_code.
    IF lv_x IS INITIAL.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
