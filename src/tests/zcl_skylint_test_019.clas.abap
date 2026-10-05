CLASS zcl_skylint_test_019 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_019 IMPLEMENTATION.
  METHOD with_finding.
    CASE lv_type.
    WHEN 1.
    lv_x = 1.
    ENDCASE.
  ENDMETHOD.

  METHOD clean_code.
    CASE lv_type.
    WHEN 1.
    lv_x = 1.
    WHEN 2.
    lv_x = 2.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
