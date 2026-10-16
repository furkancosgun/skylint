CLASS lcl_bad DEFINITION.
  PUBLIC SECTION.
    METHODS get_status RETURNING VALUE(rv_flag) TYPE abap_bool.
ENDCLASS.
CLASS lcl_bad IMPLEMENTATION.
  METHOD get_status.
    rv_flag = abap_true.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_clean DEFINITION.
  PUBLIC SECTION.
    METHODS is_valid RETURNING VALUE(rv_flag) TYPE abap_bool.
ENDCLASS.
CLASS lcl_clean IMPLEMENTATION.
  METHOD is_valid.
    rv_flag = abap_true.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_calc DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS validate_input RETURNING VALUE(rv_ok) TYPE flag.
ENDCLASS.
CLASS lcl_calc IMPLEMENTATION.
  METHOD validate_input.
    RETURN.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_state DEFINITION.
  PUBLIC SECTION.
    METHODS has_entries RETURNING VALUE(rv_flag) TYPE xfeld.
ENDCLASS.
CLASS lcl_state IMPLEMENTATION.
  METHOD has_entries.
    rv_flag = abap_true.
  ENDMETHOD.
ENDCLASS.

CLASS zcl_test_prefer_predicate_name DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS test_001.
    METHODS test_002.
    METHODS test_003.
    METHODS test_004.
ENDCLASS.

CLASS zcl_test_prefer_predicate_name IMPLEMENTATION.
  METHOD test_001.
    RETURN.
  ENDMETHOD.

  METHOD test_002.
    RETURN.
  ENDMETHOD.

  METHOD test_003.
    RETURN.
  ENDMETHOD.

  METHOD test_004.
    DATA lv_val TYPE i.
    lv_val = 1.
  ENDMETHOD.
ENDCLASS.
