CLASS zcl_skylint_test_070 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS process_data
      RETURNING VALUE(rv_ok) TYPE abap_bool.

    METHODS calculate_result
      RETURNING VALUE(rv_ok) TYPE abap_bool. "#EC BOOL_METHOD_NAME

    METHODS is_valid
      RETURNING VALUE(rv_ok) TYPE abap_bool.
ENDCLASS.


CLASS zcl_skylint_test_070 IMPLEMENTATION.
  METHOD process_data.
    rv_ok = abap_true.
  ENDMETHOD.

  METHOD calculate_result.
    rv_ok = abap_true.
  ENDMETHOD.

  METHOD is_valid.
    rv_ok = abap_true.
  ENDMETHOD.
ENDCLASS.
