CLASS zcl_skylint_test_max_line_len DEFINITION.
  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.

CLASS zcl_skylint_test_max_line_len IMPLEMENTATION.
  METHOD test_001.
    DATA lv_value TYPE i.
    lv_value = 1.
  ENDMETHOD.

  METHOD test_002.
    DATA lv_text TYPE string VALUE 'This is a long string that exceeds one hundred and twenty characters limit to trigger the check properly'.
  ENDMETHOD.
ENDCLASS.
