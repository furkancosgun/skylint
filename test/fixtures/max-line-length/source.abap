CLASS zcl_skylint_test_max_line_len DEFINITION
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
    DATA lv_extremely_long_variable_name_created_specifically_to_exceed_the_maximum_allowed_line_length_of_one_hundred_twenty_chars TYPE i.
  ENDMETHOD.
ENDCLASS.
