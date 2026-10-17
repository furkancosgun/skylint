CLASS zcl_test_prefer_string_functio DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
    METHODS test_005.
ENDCLASS.


CLASS zcl_test_prefer_string_functio IMPLEMENTATION.
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

  METHOD test_003.
    DATA lv_text TYPE string.
    CONDENSE lv_text NO-GAPS.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_text TYPE string.
    lv_text = to_lower( lv_text ).
  ENDMETHOD.

  METHOD test_005.
    DATA lv_text TYPE string.
    TRANSLATE lv_text USING 'abxy'.
  ENDMETHOD.
ENDCLASS.

