CLASS lcl_bad_naming DEFINITION.
  PUBLIC SECTION.
    DATA mv_value TYPE i.
    DATA is_order TYPE ty_order.
    METHODS process IMPORTING iv_input TYPE string.
ENDCLASS.
CLASS lcl_good_naming DEFINITION.
  PUBLIC SECTION.
    DATA value TYPE i.
    DATA is_active TYPE abap_bool.
    METHODS process IMPORTING input    TYPE string
                              is_ready TYPE abap_bool.
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
    DATA is_valid TYPE abap_bool.
  ENDMETHOD.
ENDCLASS.
