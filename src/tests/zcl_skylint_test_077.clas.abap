CLASS zcl_skylint_test_077 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.


CLASS zcl_skylint_test_077 IMPLEMENTATION.
  METHOD test_001.
    DATA lv_unused TYPE i.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_used TYPE i.
    lv_used = 1.
  ENDMETHOD.
ENDCLASS.

