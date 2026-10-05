CLASS zcl_skylint_test_072 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS with_finding.
    METHODS clean_code.
ENDCLASS.


CLASS zcl_skylint_test_072 IMPLEMENTATION.
  METHOD with_finding.
    CONDENSE lv_text.
    TRANSLATE lv_text TO UPPER CASE.
  ENDMETHOD.

  METHOD clean_code.
    lv_text = condense( lv_text ).
    lv_text = to_upper( lv_text ).
  ENDMETHOD.
ENDCLASS.
