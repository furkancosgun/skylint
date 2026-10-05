CLASS zcl_skylint_test_072 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.


CLASS zcl_skylint_test_072 IMPLEMENTATION.
  METHOD test_001.
    DATA lv_text TYPE string.
    CONDENSE lv_text.
    TRANSLATE lv_text TO UPPER CASE.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_text TYPE string.
    lv_text = condense( lv_text ).
    lv_text = to_upper( lv_text ).
  ENDMETHOD.
ENDCLASS.

