CLASS zcl_skylint_test_042 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.

  PRIVATE SECTION.
    METHODS get_value_exporting EXPORTING ev_val TYPE i.
    METHODS get_value_returning RETURNING VALUE(rv_val) TYPE i.
ENDCLASS.

CLASS zcl_skylint_test_042 IMPLEMENTATION.
  METHOD test_001.
    RETURN.
  ENDMETHOD.

  METHOD test_002.
    RETURN.
  ENDMETHOD.

  METHOD get_value_exporting.
    RETURN.
  ENDMETHOD.

  METHOD get_value_returning.
    RETURN.
  ENDMETHOD.
ENDCLASS.
