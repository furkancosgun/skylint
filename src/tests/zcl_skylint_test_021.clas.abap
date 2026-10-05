CLASS zcl_skylint_test_021 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_021 IMPLEMENTATION.
  METHOD with_finding.
    IF lv_a EQ lv_b.
    ENDIF.
  ENDMETHOD.

  METHOD clean_code.
    IF lv_a = lv_b.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
