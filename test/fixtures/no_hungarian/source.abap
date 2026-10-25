CLASS lcl_bad_naming DEFINITION.
  PUBLIC SECTION.
    DATA mv_value TYPE i.
    METHODS process IMPORTING iv_input TYPE string.
ENDCLASS.
CLASS lcl_good_naming DEFINITION.
  PUBLIC SECTION.
    DATA value TYPE i.
    METHODS process IMPORTING input TYPE string.
ENDCLASS.
CLASS zcl_skylint_test_hungarian DEFINITION.
  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
ENDCLASS.
CLASS zcl_skylint_test_hungarian IMPLEMENTATION.
  METHOD test_001.
    DATA lv_text TYPE string.
  ENDMETHOD.
  METHOD test_002.
    DATA text TYPE string.
  ENDMETHOD.
ENDCLASS.
