CLASS zcl_skylint_test_077 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_077 IMPLEMENTATION.
  METHOD with_finding.
    DATA lv_unused TYPE i.
  ENDMETHOD.

  METHOD clean_code.
    DATA lv_used TYPE i.
    lv_used = 1.
  ENDMETHOD.
ENDCLASS.
