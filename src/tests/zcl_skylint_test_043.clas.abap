CLASS zcl_skylint_test_043 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.

  PRIVATE SECTION.
    METHODS get_data_classic EXCEPTIONS not_found.
    METHODS get_data_clean RAISING cx_static_check.
ENDCLASS.

CLASS zcl_skylint_test_043 IMPLEMENTATION.
  METHOD test_001.
    RETURN.
  ENDMETHOD.

  METHOD test_002.
    RETURN.
  ENDMETHOD.

  METHOD get_data_classic.
    RETURN.
  ENDMETHOD.

  METHOD get_data_clean.
    RETURN.
  ENDMETHOD.
ENDCLASS.
