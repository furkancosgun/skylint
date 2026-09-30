CLASS zcl_skylint_test_097 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS method_one IMPORTING !iv_param TYPE string.
    METHODS method_two IMPORTING !iv_param TYPE string. "#EC UNNECESSARY_ESCAPE
    METHODS method_three IMPORTING !exporting TYPE string.
    METHODS method_four IMPORTING iv_param TYPE string.
ENDCLASS.


CLASS zcl_skylint_test_097 IMPLEMENTATION.
  METHOD method_one.
  ENDMETHOD.

  METHOD method_two.
  ENDMETHOD.

  METHOD method_three.
  ENDMETHOD.

  METHOD method_four.
  ENDMETHOD.
ENDCLASS.
