CLASS zcl_skylint_test_053 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_053 IMPLEMENTATION.
  METHOD with_finding.
    DATA lv_x LIKE mara-matnr.
  ENDMETHOD.

  METHOD clean_code.
    DATA lv_x TYPE mara-matnr.
  ENDMETHOD.
ENDCLASS.
