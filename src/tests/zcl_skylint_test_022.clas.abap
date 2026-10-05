CLASS zcl_skylint_test_022 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_022 IMPLEMENTATION.
  METHOD with_finding.
    CREATE OBJECT lo_obj.
  ENDMETHOD.

  METHOD clean_code.
    CREATE OBJECT lo_obj TYPE (lv_cls).
  ENDMETHOD.
ENDCLASS.
