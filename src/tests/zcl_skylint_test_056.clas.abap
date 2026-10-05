CLASS zcl_skylint_test_056 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.

  PRIVATE SECTION.
    METHODS get_status RETURNING VALUE(rv_flag) TYPE abap_bool.
    METHODS is_valid RETURNING VALUE(rv_flag) TYPE abap_bool.
ENDCLASS.

CLASS zcl_skylint_test_056 IMPLEMENTATION.
  METHOD test_001.
    RETURN.
  ENDMETHOD.

  METHOD test_002.
    RETURN.
  ENDMETHOD.

  METHOD get_status.
    rv_flag = abap_true.
  ENDMETHOD.

  METHOD is_valid.
    rv_flag = abap_true.
  ENDMETHOD.
ENDCLASS.
